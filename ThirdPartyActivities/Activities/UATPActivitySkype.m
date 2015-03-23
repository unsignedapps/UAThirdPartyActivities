//
//  UATPActivitySkype.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 4/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivitySkype.h"
#import "UATPPrivateURL.h"

@interface UATPActivitySkype ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivitySkype

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
    return @"com.unsignedapps.thirdpartyactivities.skype";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-skype", @"UATPLocalizable", @"Action Title for Skype");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"open-in-skype"];
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
            NSURL *skypeURL = [self skypeURLForURL:url];
            if (skypeURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:skypeURL])
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
        url = [self.class skypeURLForURL:url];
        
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

+ (NSURL *)skypeURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    // not a supported scheme?
    if (![url.scheme isEqualToString:@"tel"])
        return nil;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"skype:%@?call", url.resourceSpecifier]];
}

@end
