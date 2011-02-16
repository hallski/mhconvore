//
//  MHConvMessage.m
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import "MHConvoreMessage.h"
#import "MHConvoreTopic.h"
#import "MHConvoreUser.h"

@implementation MHConvoreMessage
@synthesize user;
@synthesize topic;
@synthesize group;
@synthesize date;
@synthesize messageId;
@synthesize message;
@synthesize renderedMessage;

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
   // NSLog(@"Init with dictionary: %@", dict);
    
    self.message = [dict valueForKey:@"message"];
    self.renderedMessage = [dict valueForKey:@"rendered"];
    self.messageId = [dict valueForKey:@"id"];
    self.topic = [[[MHConvoreTopic alloc] initWithDictionary:[dict valueForKey:@"topic"]] autorelease];
    self.user = [[[MHConvoreUser alloc] initWithDictionary:[dict valueForKey:@"user"]] autorelease];
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
