//
//  UATPActivityTwitter.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 4/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityTwitter.h"
#import "NSURL+UAQueryStringDictionary.h"
#import "UATPPrivateURL.h"

@interface UATPActivityTwitter ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityTwitter

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
    return @"com.unsignedapps.thirdpartyactivities.twitter";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-twitter", @"UATPLocalizable", @"Action Title for Twitter");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"open-in-twitter"];
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
            NSURL *twitterURL = [self twitterURLForURL:url];
            
            if (twitterURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:twitterURL])
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
        
        // great, now we need to chrome-ify it
        NSURL *twitterURL = [self.class twitterURLForURL:url];
        if (twitterURL == nil)
            continue;
        
        UIApplication *app = [UIApplication sharedApplication];
        if (![app canOpenURL:twitterURL])
        {
            // if its not supported we can't recover with any other URL type
            [self activityDidFinish:NO];
            return;
        }
        
        [app openURL:twitterURL];
        [self activityDidFinish:YES];
        return;
    }
    
    [self activityDidFinish:NO];
}

/**
 * Utilities
 **/

+ (NSURL *)twitterURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    // twitter.com URLs
    if (url.host != nil && [url.host rangeOfString:@"twitter.com"].location != NSNotFound)
    {
        // is it a twitter status?
        NSRegularExpression *statusRegex = [NSRegularExpression regularExpressionWithPattern:@"\\/status(es)?\\/([0-9]+)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *result = [statusRegex firstMatchInString:url.path options:kNilOptions range:NSMakeRange(0, url.path.length)];
        if (result != nil && result.range.location != NSNotFound && result.numberOfRanges > 2 && [result rangeAtIndex:2].location != NSNotFound)
        {
            NSString *statusID = [url.path substringWithRange:[result rangeAtIndex:2]];
            return [NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", statusID]];
        }
        
        // is it the search page?
        if ([url.path rangeOfString:@"/search"].location == 0)
        {
            NSDictionary *query = url.UAQueryDictionary;
            if (query != nil && query[@"q"] != nil && [query[@"q"] length] > 0)
                return [NSURL URLWithString:[NSString stringWithFormat:@"twitter://search?query=%@", query[@"q"]]];
            
            // no luck here
            return nil;
        }
        
        // is it a user page?
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\/([a-z0-9_]+)\\/?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *userResult = [regex firstMatchInString:url.path options:kNilOptions range:NSMakeRange(0, url.path.length)];
        if (userResult != nil && userResult.range.location != NSNotFound && userResult.numberOfRanges > 1 && [userResult rangeAtIndex:1].location != NSNotFound)
        {
            NSString *username = [url.path substringWithRange:[userResult rangeAtIndex:1]];
            return [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", username]];
        }
        
        // can't support others at this stage
        return nil;
    }
    
    // is it already a twitter: link?
    if ([url.scheme isEqualToString:@"twitter"])
        return url;
    
    // not supported
    return nil;
}

@end
