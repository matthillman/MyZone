//
//  ScrollingChartView.h
//  MyZone
//
//  Created by Matthew Hillman on 2/19/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollingChartView : UIView
/**
 * NSArray of GraphPoint objects. The CGPoint represents the bar: point.x is the bar
 * beginning and point.y is the height of the bar. The width is based on the frame size;
 */
@property (strong, nonatomic) NSArray *points;
/**
 * Dictionary of fill colors in this format. If no color is found then an appropriate one will be chosen for you.
 *
 * Category => @{@"stroke": UIColor, @"fill": UIColor}
 */
@property (strong, nonatomic) NSDictionary *colors;

@property (weak, nonatomic) id target;
@property (assign, nonatomic) SEL action;
@end
