//
//  NSValue+MZValue.m
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "NSValue+MZValue.h"

@implementation NSValue (MZValue)
+ (NSValue *)valueWithMZPoint:(MZPoint)point
{
    return [NSValue value:&point withObjCType:@encode(MZPoint)];
}

- (MZPoint)mzPointValue
{
    MZPoint p;
    [self getValue:&p];
    return p;
}
@end
