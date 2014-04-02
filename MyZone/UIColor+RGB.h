//
//  UIColor+RGB.h
//  Ratio
//
//  Created by Matthew Hillman on 9/23/13.
//  Copyright (c) 2013 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGB)
+ (UIColor *)colorForR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(CGFloat)a;
+ (UIColor *)colorForHex:(NSInteger)hex;
+ (UIColor *)fillColorForZone:(MZZoneKey)zone;
@end
