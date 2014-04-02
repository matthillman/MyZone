//
//  CenteringScrollView.m
//  MyZone
//
//  Created by Matthew Hillman on 2/19/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "CenteringScrollView.h"

@implementation CenteringScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.tileContainerView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 4;
    else
        frameToCenter.origin.y = 0;
    
    self.tileContainerView.frame = frameToCenter;
}

@end
