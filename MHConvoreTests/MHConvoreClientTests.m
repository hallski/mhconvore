//
//  MHConvoreClientTests.m
//  MHConvore
//
//  Created by Mikael Hallendal on 2011-02-17.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import "MHConvoreClientTests.h"
#import "MHConvoreClient.h"


@implementation MHConvoreClientTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testBaseURL
{
    STAssertEqualObjects([NSURL URLWithString:@"https://convore.com"], [MHConvoreClient baseURL], nil);
}

@end
