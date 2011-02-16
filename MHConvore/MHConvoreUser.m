//
//  MHConvUser.m
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Tinybird Interactive AB. All rights reserved.
//

#import "MHConvoreUser.h"
#import "MHConvoreClient.h"

@implementation MHConvoreUser
@synthesize name;
@synthesize userId;
@synthesize avatarURL;
@synthesize url;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    
  //  NSLog(@"User from dict: %@", dict);
    
    self.name = [dict valueForKey:@"username"];
    self.userId = [dict valueForKey:@"id"];
    self.avatarURL = [dict valueForKey:@"img"];
    self.url = [NSURL URLWithString:[dict valueForKey:@"url"] relativeToURL:[MHConvoreClient baseURL]];
    
    // NSLog(@"User URL: %@", [self.url absoluteString]);
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
