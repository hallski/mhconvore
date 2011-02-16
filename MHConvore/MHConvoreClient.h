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


// Delegate based API or block?

// live.json: https://convore.com/api/live.json
// Get live updates about activity on the site.
// Required parameters: group_id (if unauthenticated)
// Optional Parameters: cursor, topic_id

// Updates include new message notifications, new topic notifications, message deletion notifications, 
// member log in and log out notifications, etc.
- (void)listen;

// Block based API for these

// Account/Verify: https://convore.com/api/account/verify.json
// Use this method to check if the user is properly logged in.
- (void)verifyAccount:(void (^) (MHConvoreUser *user, NSError *error))block;

// groups: https://convore.com/api/groups.json
// Get a list of the current user's groups.
- (void)groups:(void (^) (NSArray *groups, NSError *error))block;

// groups/:group_id: https://convore.com/api/groups/:group_id.json
// Get detailed information about the group.
// Required parameters: group_id
- (void)infoForGroup:(NSString *)groupId block:(void (^) (MHConvoreGroup *group, NSError *error))block;

// groups/create: https://convore.com/api/groups/create.json
// Create a new group.
// Request method: POST
// Required parameters: name
// Optional Parameters: description, slug
- (void)createGroupWithName:(NSString *)name 
                description:(NSString *)description
                       slug:(NSString *)slug
                      block:(void (^)(MHConvoreGroup *group, NSError *error))block;

// groups/:group_id/leave: https://convore.com/api/groups/:group_id/leave.json
// Leave a group.
// Request method: POST
// Required parameters: group_id
- (void)leaveGroupWithName:(NSString *)name block:(void (^) (id something, NSError *error))block;

// groups/:group_id/topics: https://convore.com/api/groups/:group_id/topics.json
// Get the latest topics in a group.
// Required parameters: group_id
- (void)topicsInGroup:(NSString *)groupId block:(void (^) (NSArray *topics, NSError *error))block;

// groups/:group_id/topics/create: https://convore.com/api/groups/:group_id/topics/create.json
// Create a new topic.
// Request method: POST
// Required parameters: group_id, name
- (void)createTopicWithName:(NSString *)name
                    inGroup:(NSString *)groupId
                      block:(void (^) (MHConvoreTopic *topic, NSError *error))block;

// topics/:topic_id: https://convore.com/api/topics/:topic_id.json
// Get detailed information about the topic.
// Required parameters: topic_id
- (void)infoForTopic:(NSString *)topicId block:(void (^) (MHConvoreTopic *topic, NSError *error))block;

// topics/:topic_id/messages: https://convore.com/api/topics/:topic_id/messages.json
// Get the latest messages in a topic.
// Required parameters: topic_id
- (void)messagesInTopic:(NSString *)topicId block:(void (^) (NSArray *messages, NSError *error))block;

// topics/:topic_id/messages/create: https://convore.com/api/topics/:topic_id/messages/create.json
// Post a new message.
// Request method: POST
// Required parameters: topic_id, message
- (void)postMessage:(NSString *)message 
            inTopic:(NSString *)topicId
              block:(void (^) (MHConvoreMessage *message, NSError *error))block;

@end
