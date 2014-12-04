//
//  NSURL+UAQueryStringDictionary.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 4/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "NSURL+UAQueryStringDictionary.h"

@implementation NSURL (UAQueryStringDictionary)

- (NSDictionary *)UAQueryDictionary
{
    if (self.query == nil || self.query.length == 0)
        return nil;
    
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [self.query componentsSeparatedByString:@"&"])
    {
        NSArray *components = [query componentsSeparatedByString:@"="];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = nil;
        if (components.count == 1)
        {
            // key with no value
            value = [NSNull null];
        }
        if (components.count == 2)
        {
            value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // cover case where there is a separator, but no actual value
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2)
        {
            // invalid - ignore this pair. is this best, though?
            continue;
        }
        mute[key] = value ?: [NSNull null];
    }
    return mute.count ? mute.copy : nil;
}

@end
