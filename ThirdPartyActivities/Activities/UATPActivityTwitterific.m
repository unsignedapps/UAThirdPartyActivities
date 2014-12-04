//
//  UATPActivityTwitterific.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 4/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityTwitterific.h"
#import "UATPActivityTwitter.h"
#import "NSURL+UAQueryStringDictionary.h"
#import "UATPPrivateURL.h"

@interface UATPActivityTwitterific ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityTwitterific

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
    return @"com.unsignedapps.thirdpartyactivities.twitterific";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-twitterific", @"UATPLocalizable", @"Action Title for Twitterific");
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
            NSURL *twitterURL = [UATPActivityTwitter twitterURLForURL:url];
            if (twitterURL == nil)
                continue;
            
            // now how about tweetbot?
            NSURL *twitterificURL = [self twitterificURLForURL:url];
            if (twitterificURL == nil)
                continue;
            
            // make sure we can open it
            if ([[UIApplication sharedApplication] canOpenURL:twitterificURL])
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
        
        // great, now we need to
        NSURL *twitterURL = [UATPActivityTwitter twitterURLForURL:url];
        if (twitterURL == nil)
            continue;
        
        NSURL *twitterificURL = [self.class twitterificURLForURL:url];
        if (twitterificURL == nil)
            continue;
        
        UIApplication *app = [UIApplication sharedApplication];
        if (![app canOpenURL:twitterificURL])
        {
            // if its not supported we can't recover with any other URL type
            [self activityDidFinish:NO];
            return;
        }
        
        [app openURL:twitterificURL];
        [self activityDidFinish:YES];
        return;
    }
    
    [self activityDidFinish:NO];
}

/**
 * Utilities
 **/

+ (NSURL *)twitterificURLForURL:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    // not a twitter: url?
    if (![url.scheme isEqualToString:@"twitter"])
        return nil;
    
    NSDictionary *query = url.UAQueryDictionary;
    
    // is it a status?
    if ([url.host isEqualToString:@"status"] && query != nil && query[@"id"] != nil)
        return [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///tweet?id=%@", query[@"id"]]];
    
    // is it a user?
    if ([url.host isEqualToString:@"user"] && query != nil && query[@"screen_name"] != nil)
        return [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///profile?screen_name=%@", query[@"screen_name"]]];
    
    // search?
    if ([url.host isEqualToString:@"search"] && query != nil && query[@"query"] != nil)
        return [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///search?q=%@", query[@"query"]]];
    
    // not supported
    return nil;
}

@end
