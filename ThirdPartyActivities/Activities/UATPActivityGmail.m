//
//  UATPActivityGmail.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityGmail.h"
#import "UATPPrivateURL.h"

@interface UATPActivityGmail ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityGmail

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
    return @"com.unsignedapps.thirdpartyactivities.gmail";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-send-gmail", @"UATPLocalizable", @"Action Title for Sending Mail via Gmail");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"open-in-gmail"];
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
            // not a supported URL?
            NSURL *gmailURL = [self gmailURLForURL:url];
            if (gmailURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:gmailURL])
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
        
        if (url == nil)
            continue;
        
        // supported URL?
        url = [self.class gmailURLForURL:url];
        if (url == nil)
            continue;
        
        UIApplication *app = [UIApplication sharedApplication];
        if (![app canOpenURL:url])
        {
            // if its not supported we can't recover with any other URL type
            [self activityDidFinish:NO];
            return;
        }
        
        [app openURL:url];
        [self activityDidFinish:YES];
        return;
    }
    
    [self activityDidFinish:NO];
}

+ (NSURL *)gmailURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    if (![url.scheme isEqualToString:@"mailto"])
        return nil;
    
    return [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"mailto:" withString:@"googlegmail:///co?to="]];
}

@end
