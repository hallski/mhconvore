//
//  NSArray+MHExtensions.h
//  MHConvore
//
//  Created by Mikael Hallendal on 2011-02-18.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (MHExtensions)
    
- (NSArray *)arrayByApplyingBlock:(id (^) (id object))block;

@end
