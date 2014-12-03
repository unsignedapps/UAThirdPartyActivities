//
//  UATPActivities.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UAThirdPartyActivities.h"

@implementation UATPActivities

+ (NSArray *)activitiesSupportingActivityItems:(NSArray *)items
{
    NSMutableArray *activities = [NSMutableArray array];

    // the ordering here is designed to be most-specific to least specific (so native clients appear before web browsers)

    // Phone Calls
    if ([UATPActivityPhoneCall canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityPhoneCall alloc] init]];

    // FaceTime Audio
    if ([UATPActivityFaceTimeAudio canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityFaceTimeAudio alloc] init]];

    // FaceTime Video
    if ([UATPActivityFaceTimeVideo canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityFaceTimeVideo alloc] init]];

    // SMS
    if ([UATPActivitySMS canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivitySMS alloc] init]];
    
    // Maps
    if ([UATPActivityMaps canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityMaps alloc] init]];
    
    // Google Maps
    if ([UATPActivityGoogleMaps canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityGoogleMaps alloc] init]];
    
    // Native Mail
    if ([UATPActivityMail canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityMail alloc] init]];
    
    // Google Mail
    if ([UATPActivityGmail canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityGmail alloc] init]];
    
    // Safari
    if ([UATPActivitySafari canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivitySafari alloc] init]];
    
    // Chrome
    if ([UATPActivityChrome canPerformWithActivityItems:items])
        [activities addObject:[[UATPActivityChrome alloc] init]];
    
    return activities;
}

+ (NSArray *)allActitivies
{
    return
    @[
        [[UATPActivityPhoneCall alloc] init],
        [[UATPActivityFaceTimeAudio alloc] init],
        [[UATPActivityFaceTimeVideo alloc] init],
        [[UATPActivitySMS alloc] init],
        [[UATPActivityMaps alloc] init],
        [[UATPActivityGoogleMaps alloc] init],
        [[UATPActivityMail alloc] init],
        [[UATPActivityGmail alloc] init],
        [[UATPActivitySafari alloc] init],
        [[UATPActivityChrome alloc] init]
    ];
}

@end
