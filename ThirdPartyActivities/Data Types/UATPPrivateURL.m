//
//  UATPPrivateURL.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 4/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPPrivateURL.h"

@implementation UATPPrivateURL

@synthesize url=_url;

- (instancetype)initWithURL:(NSURL *)url
{
    if ((self = [self init]))
    {
        [self setUrl:url];
    }
    return self;
}

+ (instancetype)privateURLWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

#pragma mark - UIActivityItemSourceDelegate Methods

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    // our placeholder is ourselves, so that the built in ones can't handle us
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    // is it one of our activities?
    return self.url;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
    return @"public.url";
}

@end
