//
//  UATPActivityTwitter.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 4/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "UATPActivityTwitter.h"

@interface UATPActivityTwitterTests : XCTestCase

@end

@implementation UATPActivityTwitterTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNormalText
{
    XCTAssertFalse([UATPActivityTwitter canPerformWithActivityItems:@[ @"xxxx" ]]);
}

- (void)testUserString
{
    XCTAssertTrue([[UATPActivityTwitter twitterURLForURL:[NSURL URLWithString:@"https://twitter.com/bok_"]].absoluteString isEqualToString:@"twitter://user?screen_name=bok_"]);
}

- (void)testStatusString
{
    NSURL *twitterURL = [UATPActivityTwitter twitterURLForURL:[NSURL URLWithString:@"https://twitter.com/_lifestyled/status/531317029354352641"]];
    XCTAssertTrue([twitterURL.absoluteString isEqualToString:@"twitter://status?id=531317029354352641"]);
}

@end
