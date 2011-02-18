//
//  NSArray+MHExtensions.m
//  MHConvore
//
//  Created by Mikael Hallendal on 2011-02-18.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import "NSArray+MHExtensions.h"


@implementation NSArray (MHExtensions)

- (NSArray *)arrayByApplyingBlock:(id (^) (id object))block
{
    NSMutableArray *retVal = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (id object in self) {
        id newObject = block(object);
        if (newObject) {
            [retVal addObject:newObject];
        }
    }
    
    return [NSArray arrayWithArray:retVal];
}

@end
