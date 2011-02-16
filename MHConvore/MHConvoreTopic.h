//
//  MHConvTopic.h
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MHConvoreTopic : NSObject {
@private
    NSString *topicId;
    NSString *name;
    NSURL *url;
}
@property(nonatomic, copy) NSString *topicId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, retain) NSURL *url;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
