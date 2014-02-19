//
//  HorizontalScalingView.m
//  MyZone
//
//  Created by Matthew Hillman on 2/19/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "HorizontalScalingView.h"

@implementation HorizontalScalingView

- (void)setTransform:(CGAffineTransform)transform
{
    CGAffineTransform constrainedTransform = CGAffineTransformIdentity;
    constrainedTransform.a = transform.a;
    [super setTransform:constrainedTransform];
}

@end
