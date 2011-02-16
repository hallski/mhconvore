//
//  MHConvUser.h
//  Convore
//
//  Created by Mikael Hallendal on 2011-02-15.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MHConvoreUser : NSObject {
@private
    NSString *name;
    NSString *userId;
    NSString *avatarURL;
    NSURL *url;
}
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *userId;
@property(nonatomic, copy) NSString *avatarURL;
@property(nonatomic, retain) NSURL *url;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
