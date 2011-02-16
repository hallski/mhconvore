//
//  MHConvoreClient.m
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import "MHConvoreClient.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "MHConvoreMessage.h"

@implementation MHConvoreClient
@synthesize listener;
@synthesize username;
@synthesize password;
@synthesize cursor;

+ (MHConvoreClient *)clientWithUsername:(NSString *)username password:(NSString *)password
{
    return [[[MHConvoreClient alloc] initWithUsername:username password:password] autorelease];
}

+ (NSURL *)baseURL
{
    return [NSURL URLWithString:@"https://convore.com"];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithUsername:(NSString *)uname password:(NSString *)pword
{
    [self init];
    self.username = uname;
    self.password = pword;
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Listener Dispatching
- (void)dispatchMessage:(NSDictionary *)message
{
    NSLog(@"Dispatch message: %@", message);
    if ([self.listener respondsToSelector:@selector(newMessage:)]) {
        [self.listener newMessage:[[[MHConvoreMessage alloc] initWithDictionary:message] autorelease]];
    }   
}

- (void)dispatchLogin:(NSDictionary *)message
{
    // Handle group ids
    if ([self.listener respondsToSelector:@selector(login:)]) {
        [self.listener login:[[[MHConvoreUser alloc] initWithDictionary:[message valueForKey:@"user"]] autorelease]];
    }
}

- (void)dispatchLogout:(NSDictionary *)message
{
    // Handle group ids
    if ([self.listener respondsToSelector:@selector(logout:)]) {
        [self.listener logout:[[[MHConvoreUser alloc] initWithDictionary:[message valueForKey:@"user"]] autorelease]];
    }    
}

- (void)dispatchTopic:(NSDictionary *)message
{
    NSLog(@"Dispatch new topic: %@", message);
}

- (NSString *)dispatchSelectorFromKind:(NSString *)kind
{
    return [NSString stringWithFormat:@"dispatch%@:", [kind capitalizedString]];
}

- (void)dispatchMessageFromDict:(NSDictionary *)message
{
    NSString *kind = [message valueForKey:@"kind"];
    
    SEL selector = NSSelectorFromString([self dispatchSelectorFromKind:kind]);
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector withObject:message];
    } else {
        NSLog(@"Unhandled message of kind '%@':\n%@", kind, message);
    }
}

#pragma mark -
#pragma mark Request creation
- (void)setupHTTPRequest:(ASIHTTPRequest *)request
{
    [request setUsername:self.username];
    [request setPassword:self.password];
    [request setTimeOutSeconds:60];
}

- (NSURL *)urlForRequestWithPath:(NSString *)path
{
    return [NSURL URLWithString:path relativeToURL:[MHConvoreClient baseURL]];
}

- (ASIHTTPRequest *)requestForPath:(NSString *)path
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self urlForRequestWithPath:path]];

    [self setupHTTPRequest:request];
    
    return request;
}

- (ASIFormDataRequest *)postRequestForPath:(NSString *)path
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[self urlForRequestWithPath:path]];
    
    [self setupHTTPRequest:request];
    
    return request;
}

- (id)jsonObjectFromString:(NSString *)string ofClass:(Class)class
{
    id jsonObject = [string JSONValue];
    if ([jsonObject isKindOfClass:class]) {
        return jsonObject;
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark Send requests
- (void)sendRequest:(ASIHTTPRequest *)request
    withFinishBlock:(void (^) (id obj, NSError *error))finishBlock
  createObjectBlock:(id (^) (NSDictionary *json))objectBlock
{
    [request setCompletionBlock:^ {
        NSDictionary *json = [self jsonObjectFromString:[request responseString] ofClass:[NSDictionary class]];
        if (json) {
            if ([json valueForKey:@"error"] != nil) {
                finishBlock(nil, nil /* invent error */);
            } else {
                finishBlock(objectBlock(json), nil);
            }
        } else {
            finishBlock(nil, nil /* invent error */);
        }
    }];
    
    [request setFailedBlock:^ {
        NSLog(@"Failed: %@", [request error]);
        finishBlock(nil, [request error]);
    }];
    
    [request startAsynchronous];
}

- (void)sendRequestForPath:(NSString *)path
           withFinishBlock:(void (^) (id obj, NSError *error))finishBlock
         createObjectBlock:(id (^) (NSDictionary *json))objectBlock
{
    __block ASIHTTPRequest *request = [self requestForPath:path];
    
    [self sendRequest:request withFinishBlock:finishBlock createObjectBlock:objectBlock];
}

- (void)sendPostRequestForPath:(NSString *)path
                    parameters:(NSDictionary *)parameters
               withFinishBlock:(void (^) (id obj, NSError *error))finishBlock
             createObjectBlock:(id (^) (NSDictionary *json))objectBlock
{
    __block ASIFormDataRequest *request = [self postRequestForPath:path];
    
    for (NSString *key in [parameters keyEnumerator]) {
        [request setPostValue:[parameters valueForKey:key] forKey:key];
    }
    
    [self sendRequest:request withFinishBlock:finishBlock createObjectBlock:objectBlock];
}

#pragma mark -
#pragma mark Public API
// Needs to be made asynchronous
- (void)listen
{
    NSLog(@"Starting to listen");
    
    __block ASIHTTPRequest *request = [self requestForPath:@"/api/live.json"];
    
    [request setCompletionBlock:^ {
        SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *dict = [jsonParser objectWithString:[request responseString]];

        for (NSDictionary *message in (NSArray *)[dict valueForKey:@"messages"]) {
            [self dispatchMessageFromDict:message];
        }
        
        [self listen];
    }];
    
    [request setFailedBlock:^ {
        NSLog(@"Error 2: %@", [request error]);
        
        [self listen];
    }];
    
    [request startAsynchronous];
    
    // Do a listen call, handle response and then call listen again.
}


// Account/Verify: https://convore.com/api/account/verify.json
// Use this method to check if the user is properly logged in.
- (void)verifyAccount:(void (^) (MHConvoreUser *user, NSError *error))block;
{
    NSLog(@"Sending verify");
    [self sendRequestForPath:@"/api/account/verify.json" 
             withFinishBlock:block
           createObjectBlock:^id(NSDictionary *json) {
               return [[[MHConvoreUser alloc] initWithDictionary:json] autorelease];
           }];
}

// groups: https://convore.com/api/groups.json
// Get a list of the current user's groups.
- (void)groups:(void (^) (NSArray *groups, NSError *error))block
{
    [self sendRequestForPath:@"/api/groups.json" 
             withFinishBlock:block
           createObjectBlock:^id(NSDictionary *json) {
               NSMutableArray *groups = [NSMutableArray array];
               for (NSDictionary *dict in [json valueForKey:@"groups"]) {
                   [groups addObject:[[[MHConvoreGroup alloc] initWithDictionary:dict] autorelease]];
               }
               return [NSArray arrayWithArray:groups];
           }];
}

// groups/:group_id: https://convore.com/api/groups/:group_id.json
// Get detailed information about the group.
// Required parameters: group_id
- (void)infoForGroup:(NSString *)groupId block:(void (^) (MHConvoreGroup *group, NSError *error))block
{
    [self sendRequestForPath:[NSString stringWithFormat:@"/api/groups/%@.json", groupId]
             withFinishBlock:block
           createObjectBlock:^id(NSDictionary *json) {
               return [[[MHConvoreGroup alloc] initWithDictionary:[json valueForKey:@"group"]] autorelease];
           }];
}

// groups/create: https://convore.com/api/groups/create.json
// Create a new group.
// Request method: POST
// Required parameters: name
// Optional Parameters: description, slug
- (void)createGroupWithName:(NSString *)name 
                description:(NSString *)description
                       slug:(NSString *)slug
                      block:(void (^)(MHConvoreGroup *group, NSError *))block
{
    // FIXME: Seems it doesn't work at the moment. Complains that we do not give any name.
    // JSON: { error = "Group name required."; }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:name forKey:@"name"];
    if (description) {
        [parameters setValue:description forKey:@"description"];
    }
    if (slug) {
        [parameters setValue:slug forKey:@"slug"];
    }
    
    [self sendPostRequestForPath:@"/api/groups/create.json"
                      parameters:parameters
                 withFinishBlock:block
               createObjectBlock:^id(NSDictionary *json) {
                   return [[[MHConvoreGroup alloc] initWithDictionary:[json valueForKey:@"group"]] autorelease];
               }];
}

// groups/:group_id/leave: https://convore.com/api/groups/:group_id/leave.json
// Leave a group.
// Request method: POST
// Required parameters: group_id
- (void)leaveGroupWithName:(NSString *)groupId block:(void (^) (id something, NSError *error))block
{
    [self sendPostRequestForPath:[NSString stringWithFormat:@"/api/groups/%@/leave.json", groupId]
                      parameters:[NSDictionary dictionaryWithObject:groupId forKey:@"group_id"]
                 withFinishBlock:block
               createObjectBlock:^id(NSDictionary *json) {
                   NSLog(@"Not sure what this json contains: %@", json);
                   return nil;
               }];
}

// groups/:group_id/topics: https://convore.com/api/groups/:group_id/topics.json
// Get the latest topics in a group.
// Required parameters: group_id
- (void)topicsInGroup:(NSString *)groupId block:(void (^) (NSArray *topics, NSError *error))block
{
    [self sendRequestForPath:[NSString stringWithFormat:@"/api/groups/%@/topics.json", groupId] 
             withFinishBlock:block
           createObjectBlock:^id(NSDictionary *json) {
               NSMutableArray *topics = [NSMutableArray array];
               for (NSDictionary *dict in [json valueForKey:@"topics"]) {
                   [topics addObject:[[[MHConvoreTopic alloc] initWithDictionary:dict] autorelease]];
               }
               return [NSArray arrayWithArray:topics];
           }];
}

// groups/:group_id/topics/create: https://convore.com/api/groups/:group_id/topics/create.json
// Create a new topic.
// Request method: POST
// Required parameters: group_id, name
- (void)createTopicWithName:(NSString *)name
                    inGroup:(NSString *)groupId
                      block:(void (^) (MHConvoreTopic *topic, NSError *error))block
{
    [self sendPostRequestForPath:[NSString stringWithFormat:@"/api/groups/%@/topics/create.json", groupId]
                      parameters:[NSDictionary dictionaryWithObject:name forKey:@"name"]
                 withFinishBlock:block
               createObjectBlock:^id(NSDictionary *json) {
                   return [[[MHConvoreTopic alloc] initWithDictionary:[json valueForKey:@"topic"]] autorelease];
               }];
}

// topics/:topic_id: https://convore.com/api/topics/:topic_id.json
// Get detailed information about the topic.
// Required parameters: topic_id
- (void)infoForTopic:(NSString *)topicId block:(void (^) (MHConvoreTopic *topic, NSError *error))block
{
    [self sendRequestForPath:[NSString stringWithFormat:@"/api/topics/%@.json", topicId]
             withFinishBlock:block
           createObjectBlock:^id(NSDictionary *json) {
               return [[[MHConvoreTopic alloc] initWithDictionary:[json valueForKey:@"topic"]] autorelease];
           }];
}

// topics/:topic_id/messages: https://convore.com/api/topics/:topic_id/messages.json
// Get the latest messages in a topic.
// Required parameters: topic_id
- (void)messagesInTopic:(NSString *)topicId block:(void (^) (NSArray *messages, NSError *error))block
{
    [self sendRequestForPath:[NSString stringWithFormat:@"/api/topics/%@/messages.json", topicId]
             withFinishBlock:block
           createObjectBlock:^id(NSDictionary *json) {
               NSMutableArray *messages = [NSMutableArray array];
               for (NSDictionary *message in [json valueForKey:@"messages"]) {
                   [messages addObject:[[[MHConvoreMessage alloc] initWithDictionary:message] autorelease]];
               }
               return [NSArray arrayWithArray:messages];
           }];
}

// topics/:topic_id/messages/create: https://convore.com/api/topics/:topic_id/messages/create.json
// Post a new message.
// Request method: POST
// Required parameters: topic_id, message
- (void)postMessage:(NSString *)message 
            inTopic:(NSString *)topicId
              block:(void (^) (MHConvoreMessage *message, NSError *error))block

{
    [self sendPostRequestForPath:[NSString stringWithFormat:@"/api/topics/%@/messages/create.json", topicId]
                      parameters:[NSDictionary dictionaryWithObject:message forKey:@"message"]
                 withFinishBlock:block
               createObjectBlock:^id(NSDictionary *json) {
                   return [[[MHConvoreMessage alloc] initWithDictionary:[json valueForKey:@"message"]] autorelease];
               }];
}


@end
