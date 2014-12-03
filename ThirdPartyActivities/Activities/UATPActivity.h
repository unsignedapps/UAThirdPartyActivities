//
//  UATPActivity.h
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UATPActivity : UIActivity

/**
 * Whether or not the activity can support the provided activity items.
**/
+ (BOOL)canPerformWithActivityItems:(NSArray *)activityItems;

@end
