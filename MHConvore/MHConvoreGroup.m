//
//  MHConvGroup.m
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import "MHConvoreGroup.h"

#import "MHConvoreClient.h"
#import "MHConvoreUser.h"

@implementation MHConvoreGroup
@synthesize groupId;
@synthesize name;
@synthesize description;
@synthesize slug;
@synthesize kind;
@synthesize creator;
@synthesize creationDate;
@synthesize url;
@synthesize unreadCount;
@synthesize topicsCount;

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
  //  NSLog(@"Group from dict: %@", dict);

    self.groupId = [dict valueForKey:@"id"];
    self.name = [dict valueForKey:@"name"];
    self.slug = [dict valueForKey:@"slug"];
    self.description = [dict valueForKey:@"description"];
    self.kind = [dict valueForKey:@"kind"];
    self.creator = [[[MHConvoreUser alloc] initWithDictionary:[dict valueForKey:@"creator"]] autorelease];
    self.url = [NSURL URLWithString:[dict valueForKey:@"url"] relativeToURL:[MHConvoreClient baseURL]];
    self.unreadCount = [[dict valueForKey:@"unread"] intValue];
    self.topicsCount = [[dict valueForKey:@"topics_count"] intValue];
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
