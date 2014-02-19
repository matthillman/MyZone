//
//  UIView+wrapper.m
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "UIView+wrapper.h"

@implementation UIView (wrapper)
+ (UIView *)viewWrappingSubview:(UIView *)subView
{
    UIView *wrapper = [[UIView alloc] initWithFrame:subView.frame];
    [wrapper addSubview:subView];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[sub(>=h)]-5-|" options:0 metrics:@{@"h": @(subView.frame.size.height)} views:@{@"sub": subView}]];
    [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sub(>=w)]-|" options:0 metrics:@{@"w": @(subView.frame.size.width)} views:@{@"sub": subView}]];
    
    return wrapper;
}
@end
