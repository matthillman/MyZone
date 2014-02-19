//
//  UIView+wrapper.h
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (wrapper)
+ (UIView *)viewWrappingSubview:(UIView *)subView;
@end
