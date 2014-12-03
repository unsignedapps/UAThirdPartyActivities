//
//  UATPActivityMail.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityMail.h"

@interface UATPActivityMail ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityMail

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
    return @"com.unsignedapps.thirdpartyactivities.mail";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-send-mail", @"UATPLocalizable", @"Action Title for Sending Mail");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"send-mail"];
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
        {
            // not a supported URL?
            if (![url.scheme isEqualToString:@"mailto"])
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
        if (![url.scheme isEqualToString:@"mailto"])
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
