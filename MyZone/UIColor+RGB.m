//
//  UIColor+RGB.m
//  Ratio
//
//  Created by Matthew Hillman on 9/23/13.
//  Copyright (c) 2013 Matthew Hillman. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor (RGB)
+ (UIColor *)colorForR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(CGFloat)a
{
    return [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a];
}

+ (UIColor *)colorForHex:(NSInteger)hex
{
    CGFloat r = (hex & 0xFF0000) >> 16;
    CGFloat g = (hex & 0x00FF00) >> 8;
    CGFloat b = (hex & 0x0000FF);
    return [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1];
}

+ (UIColor *)fillColorForZone:(MZZoneKey)zone
{
    NSInteger hexColor;
    switch (zone) {
        case MZZone1:
            hexColor = 0x75777a;
            break;
        case MZZone2:
            hexColor = 0x3b54a5;
            break;
        case MZZone3:
            hexColor = 0x0c8b44;
            break;
        case MZZone4:
            hexColor = 0xfff200;
            break;
        case MZZone5:
            hexColor = 0xed2024;
            break;
            
        default:
            hexColor = 0xbbbbbb;
            break;
    }
        
    return [UIColor colorForHex:hexColor];
}

@end
