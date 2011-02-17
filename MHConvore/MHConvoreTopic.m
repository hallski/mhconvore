//
//  MHConvTopic.m
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import "MHConvoreTopic.h"
#import "MHConvoreClient.h"


@implementation MHConvoreTopic
@synthesize topicId;
@synthesize name;
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
    
    //NSLog(@"Topic from dict: %@", dict);

    // Seems to sometimes get ID as NSNumber from JSON
    self.topicId = [[dict valueForKey:@"id"] description];
    NSLog(@"New topic with topicId of class: %@", [self.topicId class]);
    self.name = [dict valueForKey:@"name"];
    self.url = [NSURL URLWithString:[dict valueForKey:@"url"] relativeToURL:[MHConvoreClient baseURL]];
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
