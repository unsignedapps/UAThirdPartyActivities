//
//  UATPActivities.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UAThirdPartyActivities.h"

@implementation UATPActivities

+ (NSArray *)activityClasses
{
    // the ordering here is designed to be most-specific to least specific (so native clients appear before web browsers)
    return
    @[
        UATPActivityPhoneCall.class,                    // Phone Calls
        UATPActivityMail.class,                         // Native Mail App
        UATPActivityGmail.class,                        // Google Mail App
        UATPActivitySMS.class,                          // SMS App
        UATPActivityFaceTimeAudio.class,                // FaceTime Audio Calls
        UATPActivityFaceTimeVideo.class,                // FaceTime Video Calls
//        UATPActivitySkype.class,                        // Skype
        UATPActivityMaps.class,                         // Apple Maps App
        UATPActivityGoogleMaps.class,                   // Google Maps App
        UATPActivityTwitter.class,                      // Official Twitter App
        UATPActivityTweetbot.class,                     // Tweetbot
        UATPActivityTwitterific.class,                  // Twitterific
        UATPActivityInstagram.class,                    // Instagram
        UATPActivitySafari.class,                       // Safari
        UATPActivityChrome.class,                       // Chrome
    ];
}

+ (NSArray *)activitiesSupportingActivityItems:(NSArray *)items
{
    NSMutableArray *activities = [NSMutableArray array];

    for (Class klass in [self activityClasses])
    {
        NSAssert([klass isSubclassOfClass:[UATPActivity class]], @"Specified activity class does not subclass UATPActivity");

        if ([klass canPerformWithActivityItems:items])
            [activities addObject:[[klass alloc] init]];
    }
    
    return activities;
}

+ (NSArray *)allActitivies
{
    NSMutableArray *activities = [NSMutableArray array];
    
    for (Class klass in [self activityClasses])
    {
        NSAssert([klass isSubclassOfClass:[UATPActivity class]], @"Specified activity class does not subclass UATPActivity");
        [activities addObject:[[klass alloc] init]];
    }
    
    return activities;
}

@end
