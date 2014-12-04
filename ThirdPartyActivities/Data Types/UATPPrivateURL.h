//
//  UATPPrivateURL.h
//  ThirdPartyActivities
//
//  Created by Rob Amos on 4/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This data type provides a wrapper that makes a URL "private" as far as the
 * UIActivityViewController is concerned.
 *
 * That is, only activities provided by this framework will be capable of
 * using this URL, the built in types will not be able to perform
 * activities with these URLs.
 *
 * Basically, use this when you want to enable the actions provided by this
 * framework, but exclude ALL of the built in activities, such as sharing.
**/
@interface UATPPrivateURL : NSObject <UIActivityItemSource>

@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;

+ (instancetype)privateURLWithURL:(NSURL *)url;

@end
