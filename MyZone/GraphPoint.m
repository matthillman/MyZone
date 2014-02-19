//
//  GraphPoint.m
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "GraphPoint.h"

@implementation GraphPoint

- (id)initWithPoint:(CGPoint)point category:(NSString *)category
{
    if (!(self = [super init])) return nil;
    
    self.point = point;
    self.category = category;
    
    return self;
}

+ (GraphPoint *)pointFromCGPoint:(CGPoint)point category:(NSString *)category
{
    return [[GraphPoint alloc] initWithPoint:point category:category];
}

- (CGFloat)x
{
    return self.point.x;
}

- (CGFloat)y
{
    return self.point.y;
}

@end
