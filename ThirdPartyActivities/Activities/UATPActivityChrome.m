//
//  UATPActivityChrome.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityChrome.h"

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
    return NSLocalizedString(@"action-title-chrome", @"Action Title for Chrome");
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
        
        // if we have a URL we can check it
        if (url != nil)
            return [self chromeURLForURL:url] != nil;
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
        
        // great, now we need to chrome-ify it
        NSURL *chromeURL = [self.class chromeURLForURL:url];
        if (chromeURL == nil)
            continue;
        
        [[UIApplication sharedApplication] openURL:chromeURL];
        [self activityDidFinish:YES];
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
