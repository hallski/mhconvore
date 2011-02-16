//
//  MHConvGroup.h
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHConvoreUser;

@interface MHConvoreGroup : NSObject {
@private
    NSString *groupId;
    NSString *name;
    NSString *description;
    NSString *slug;
    NSString *kind;
    MHConvoreUser *creator;
    NSDate *creationDate;
    NSURL *url;
    NSInteger unreadCount;
    NSInteger topicsCount;
}
@property(nonatomic, copy) NSString *groupId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) NSString *slug;
@property(nonatomic, copy) NSString *kind; // Should not be a string [public, private]
@property(nonatomic, retain) MHConvoreUser *creator;
@property(nonatomic, retain) NSDate *creationDate; // Not implemented
@property(nonatomic, retain) NSURL *url;
@property NSInteger unreadCount;
@property NSInteger topicsCount;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
