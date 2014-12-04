//
//  UATPActivityGoogleMaps.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityGoogleMaps.h"
#import "UATPPrivateURL.h"

@interface UATPActivityGoogleMaps ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityGoogleMaps

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
    return @"com.unsignedapps.thirdpartyactivities.googlemaps";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-google-maps", @"UATPLocalizable", @"Action Title for Opening in Google Maps");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"open-in-google-maps"];
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
            NSURL *mapsURL = [self googleMapsURLForURL:url];

            if (mapsURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:mapsURL])
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
        
        // convert it
        url = [self.class googleMapsURLForURL:url];
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

+ (NSURL *)googleMapsURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    // if it is maps: convert it straight over
    if ([url.scheme isEqualToString:@"maps"])
        return [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"maps://" withString:@"comgooglemaps://"]];
    
    // if it is a maps.google.com or maps.apple.com URL
    else if (url.host != nil && ([url.host rangeOfString:@"maps.google"].location == 0 || [url.host isEqualToString:@"maps.apple.com"]))
    {
        NSString *replacement = [NSString stringWithFormat:@"%@://%@/", url.scheme, url.host];
        return [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://%@", [url.absoluteString stringByReplacingOccurrencesOfString:replacement withString:@""]]];
    }
    
    return nil;
}

@end
