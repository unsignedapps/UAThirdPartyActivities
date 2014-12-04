//
//  UATPActivityFaceTimeAudio.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityFaceTimeAudio.h"
#import "UATPPrivateURL.h"

@interface UATPActivityFaceTimeAudio ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityFaceTimeAudio

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
    return @"com.unsignedapps.thirdpartyactivities.facetime-audio";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-facetime-audio", @"UATPLocalizable", @"Action Title for Making FaceTime audio calls");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"facetime-call"];
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
            NSURL *facetimeURL = [self faceTimeURLForURL:url];
            if (facetimeURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:facetimeURL])
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
        
        // now convert to facetime
        url = [self.class faceTimeURLForURL:url];
        
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

+ (NSURL *)faceTimeURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    // not a supported scheme?
    if (![url.scheme isEqualToString:@"tel"] && ![url.scheme isEqualToString:@"mailto"] && ![url.scheme isEqualToString:@"facetime"] && ![url.scheme isEqualToString:@"facetime-audio"])
        return nil;
    
    if ([url.scheme isEqualToString:@"tel"])
        return [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"tel:" withString:@"facetime-audio://"]];
    
    else if ([url.scheme isEqualToString:@"mailto"])
        return [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"mailto:" withString:@"facetime-audio://"]];
    
    else if ([url.scheme isEqualToString:@"facetime"])
        return [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"facetime-audio:" withString:@"facetime-audio://"]];
    
    // we already support the others
    return url;
}

@end
