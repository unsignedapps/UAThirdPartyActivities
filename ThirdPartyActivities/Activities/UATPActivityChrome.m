//
//  UATPActivityChrome.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityChrome.h"
#import "UATPPrivateURL.h"

@interface UATPActivityChrome ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityChrome

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
    return @"com.unsignedapps.thirdpartyactivities.chrome";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-chrome", @"UATPLocalizable", @"Action Title for Chrome");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"open-in-chrome"];
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
            // if the host is maps.apple.com we prefer the native apps, it will redirect automatically
            if ([url.host isEqualToString:@"maps.apple.com"])
                continue;
            
            NSURL *chromeURL = [self chromeURLForURL:url];
            
            if (chromeURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:chromeURL])
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
        
        // if the host is maps.apple.com we prefer the native apps, it will redirect automatically
        if ([url.host isEqualToString:@"maps.apple.com"])
            continue;
        
        // great, now we need to chrome-ify it
        NSURL *chromeURL = [self.class chromeURLForURL:url];
        if (chromeURL == nil)
            continue;
        
        UIApplication *app = [UIApplication sharedApplication];
        if (![app canOpenURL:chromeURL])
        {
            // if its not supported we can't recover with any other URL type
            [self activityDidFinish:NO];
            return;
        }

        [app openURL:chromeURL];
        [self activityDidFinish:YES];
        return;
    }
    
    [self activityDidFinish:NO];
}

/**
 * Utilities
**/

+ (NSURL *)chromeURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);

    NSString *urlString = url.absoluteString;
    if (urlString == nil)
        return nil;
    
    // HTTP urls
    if ([urlString rangeOfString:@"http://"].location == 0)
        return [NSURL URLWithString:[urlString stringByReplacingOccurrencesOfString:@"http://" withString:@"googlechrome://"]];
    
    // HTTPS urls
    else if ([urlString rangeOfString:@"https://"].location == 0)
        return [NSURL URLWithString:[urlString stringByReplacingOccurrencesOfString:@"https://" withString:@"googlechromes://"]];
    
    // not supported
    return nil;
}

@end
