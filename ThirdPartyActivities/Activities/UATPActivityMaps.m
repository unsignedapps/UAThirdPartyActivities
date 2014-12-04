//
//  UATPActivityMaps.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityMaps.h"
#import "UATPPrivateURL.h"

@interface UATPActivityMaps ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityMaps

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
    return @"com.unsignedapps.thirdpartyactivities.maps";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-maps", @"UATPLocalizable", @"Action Title for Opening in Apple Maps");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"open-in-maps"];
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
            if (![url.scheme isEqualToString:@"maps"] && ![url.host isEqualToString:@"maps.apple.com"])
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:url])
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
        
        // supported scheme?
        if (![url.scheme isEqualToString:@"maps"] && ![url.host isEqualToString:@"maps.apple.com"])
            continue;
        
        // if its maps: we need to convert it over as the "official" scheme is the maps.apple.com one
        if ([url.scheme isEqualToString:@"maps"])
            url = [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"maps://" withString:@"http://maps.apple.com/"]];
        
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

@end
