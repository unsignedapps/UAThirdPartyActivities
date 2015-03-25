//
//  UATPActivityInstagram.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 23/03/2015.
//  Copyright (c) 2015 Unsigned Apps. All rights reserved.
//

#import "UATPActivityInstagram.h"
#import "UATPPrivateURL.h"

@interface UATPActivityInstagram ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityInstagram

@synthesize items=_items;

/**
 * Configuration
 **/

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"com.unsignedapps.thirdpartyactivities.instagram";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-instagram", @"UATPLocalizable", @"Action Title for Instagram");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"open-in-instagram"];
}

/**
 * Supporting Activity Items
 **/

+ (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems == nil || [activityItems count] == 0)
        return NO;
    
    // check if we have a URL in here
    for (id item in activityItems)
    {
        NSURL *url = nil;
        
        if ([item isKindOfClass:[NSURL class]])
            url = (NSURL *)item;
        
        else if ([item isKindOfClass:[NSString class]])
            url = [NSURL URLWithString:item];
        
        else if ([item isKindOfClass:[UATPPrivateURL class]])
            url = ((UATPPrivateURL *)item).url;
        
        // if we have a URL we can check it
        if (url != nil)
        {
            NSURL *appURL = [self appURLForURL:url];
            
            if (appURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:appURL])
                return YES;
        }
    }
    
    return NO;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return [self.class canPerformWithActivityItems:activityItems];
}

/**
 * Performing the Activity
**/

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    [self setItems:activityItems];
}

- (void)performActivity
{
    if (self.items == nil || [self.items count] == 0)
    {
        [self activityDidFinish:NO];
        return;
    }
    
    // find the first thing that can be a URL
    for (id item in self.items)
    {
        NSURL *url = nil;
        
        if ([item isKindOfClass:[NSURL class]])
            url = (NSURL *)item;
        
        else if ([item isKindOfClass:[NSString class]])
            url = [NSURL URLWithString:item];
        
        else if ([item isKindOfClass:[UATPPrivateURL class]])
            url = ((UATPPrivateURL *)item).url;
        
        if (url == nil)
            continue;
        
        // great, now we need to app-ify it
        NSURL *appURL = [self.class appURLForURL:url];
        if (appURL == nil)
            continue;
        
        UIApplication *app = [UIApplication sharedApplication];
        if (![app canOpenURL:appURL])
        {
            // if its not supported we can't recover with any other URL type
            [self activityDidFinish:NO];
            return;
        }
        
        [app openURL:appURL];
        [self activityDidFinish:YES];
        return;
    }
    
    [self activityDidFinish:NO];
}

/**
 * Utilities
**/

+ (NSURL *)appURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    // instagram.com URLs
    if (url.host != nil && [url.host rangeOfString:@"instagram.com"].location != NSNotFound)
    {
        // is it a user page?
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\/([a-z0-9_]+)\\/?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *userResult = [regex firstMatchInString:url.path options:kNilOptions range:NSMakeRange(0, url.path.length)];
        if (userResult != nil && userResult.range.location != NSNotFound && userResult.numberOfRanges > 1 && [userResult rangeAtIndex:1].location != NSNotFound)
        {
            NSString *username = [url.path substringWithRange:[userResult rangeAtIndex:1]];
            return [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", username]];
        }
        
        // can't support others at this stage
        return nil;
    }
    
    // is it already an app link?
    if ([url.scheme isEqualToString:@"instagram"])
        return url;
    
    // not supported
    return nil;
}

@end
