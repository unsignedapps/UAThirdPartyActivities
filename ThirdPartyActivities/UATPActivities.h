//
//  UATPActivities.h
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UATPActivities : NSObject

/**
 * Find third party activities that support the provided items.
 *
 * @param   items       The activity items that will be provided to -[UIActivityViewController initWithActivityItems:applicationActivities:]
 * @returns             An NSArray of UIActivity subclasses that support the provided types.
**/
+ (NSArray *)activitiesSupportingActivityItems:(NSArray *)items;

/**
 * Get all third party activities
 *
 * @returns             An NSArray of all UIActivity subclasses that this framework supports.
**/
+ (NSArray *)allActitivies;

@end
