//
//  MHConvoreClient.h
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MHConvoreMessage.h"
#import "MHConvoreGroup.h"
#import "MHConvoreTopic.h"
#import "MHConvoreUser.h"

@protocol MHConvoreClientListener <NSObject>

@optional
- (void)newMessage:(MHConvoreMessage *)message;
- (void)logout:(MHConvoreUser *)user;
- (void)login:(MHConvoreUser *)user;

@end

@interface MHConvoreClient : NSObject {
@private
    id<MHConvoreClientListener> listener;
    NSString *username;
    NSString *password;
    NSString *cursor;
}
@property(nonatomic, retain) id<MHConvoreClientListener> listener;
@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *cursor; // Need implementing

+ (MHConvoreClient *)clientWithUsername:(NSString *)username password:(NSString *)password;

+ (NSURL *)baseURL;

- (id)initWithUsername:(NSString *)username password:(NSString *)password;

// Get live updates about activity on the site.

// FIXME: Required parameters: group_id (if unauthenticated)
// FIXME: Optional Parameters: cursor, topic_id

// Updates include new message notifications, new topic notifications, message deletion notifications, 
// member log in and log out notifications, etc.
- (void)listen;

// Block based API for these

// Use this method to check if the user is properly logged in.
- (void)verifyAccount:(void (^) (MHConvoreUser *user, NSError *error))block;

// Get a list of the current user's groups.
- (void)groups:(void (^) (NSArray *groups, NSError *error))block;

// Get detailed information about the group.
- (void)infoForGroup:(NSString *)groupId block:(void (^) (MHConvoreGroup *group, NSError *error))block;

// Create a new group.
// FIXME: Currently gives an error about name not being submitted
- (void)createGroupWithName:(NSString *)name 
                description:(NSString *)description
                       slug:(NSString *)slug
                      block:(void (^)(MHConvoreGroup *group, NSError *error))block;

// Leave a group.
- (void)leaveGroupWithName:(NSString *)name block:(void (^) (id something, NSError *error))block;

// Get the latest topics in a group.
- (void)topicsInGroup:(NSString *)groupId block:(void (^) (NSArray *topics, NSError *error))block;

// Create a new topic.
- (void)createTopicWithName:(NSString *)name
                    inGroup:(NSString *)groupId
                      block:(void (^) (MHConvoreTopic *topic, NSError *error))block;

// Get detailed information about the topic.
- (void)infoForTopic:(NSString *)topicId block:(void (^) (MHConvoreTopic *topic, NSError *error))block;

// Get the latest messages in a topic.
- (void)messagesInTopic:(NSString *)topicId block:(void (^) (NSArray *messages, NSError *error))block;

// Post a new message.
- (void)postMessage:(NSString *)message 
            inTopic:(NSString *)topicId
              block:(void (^) (MHConvoreMessage *message, NSError *error))block;

@end
