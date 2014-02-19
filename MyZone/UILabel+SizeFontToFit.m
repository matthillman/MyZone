//
//  UILabel+SizeFontToFit.m
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "UILabel+SizeFontToFit.h"

@implementation UILabel (SizeFontToFit)
- (NSInteger)binarySearchForFontSizeWithMinSize:(NSInteger)minFontSize maxSize:(NSInteger)maxFontSize startingSize:(NSInteger)startingSize
{
//    LogDebug(@"\nFont size with min: %d max %d starting %d", minFontSize, maxFontSize, startingSize);
    // If the sizes are incorrect, return 0, or error, or an assertion.
    if (maxFontSize < minFontSize) {
//        LogDebug(@"Calculated Font Size: %d", startingSize);
        return startingSize;
    }
    
    // Find the middle
    NSInteger fontSize = (minFontSize + maxFontSize) / 2;
    // Create the font
    UIFont *font = [UIFont fontWithName:self.font.fontName size:fontSize];
    // Create a constraint size with max height
    CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
    // Find label size for current font size
    CGSize labelSize = [self.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
//    LogDebug(@"\n'%@'\nLabelSize: (%f x %f) Font imprint: (%f x %f) size: %d", self.text, labelSize.width, labelSize.height, self.frame.size.width, self.frame.size.height, fontSize);
    if( labelSize.height > self.frame.size.height || labelSize.width > self.frame.size.width)
        return [self binarySearchForFontSizeWithMinSize:minFontSize maxSize:fontSize-1 startingSize:fontSize];
    else
        return [self binarySearchForFontSizeWithMinSize:fontSize+1 maxSize:maxFontSize startingSize:fontSize];
}

- (void)sizeToFont
{
    // Try all font sizes from largest to smallest font
    int maxFontSize = 300;
    int minFontSize = 5;
    
    NSInteger size = [self binarySearchForFontSizeWithMinSize:minFontSize maxSize:maxFontSize startingSize:self.font.pointSize];
    
    self.font = [UIFont fontWithName:self.font.fontName size:size];
}
@end
