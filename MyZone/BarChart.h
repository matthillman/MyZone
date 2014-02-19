//
//  BarChartView.h
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarChart : NSObject
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
/**
 * If YES, view will attempt to average the data to make fewer bars if the view‘s frame is too small. Useful for thumbnails of large data sets.
 */
@property (assign, nonatomic) BOOL average;
/**
 * If YES, only bars will be rendered and view will act as if average is also yes.
 */
@property (assign, nonatomic) BOOL thumbnail;

@property (assign, nonatomic) NSRange yRange;
@property (assign, nonatomic) NSRange xRange;
- (UIImage *)renderImgaeAtSize:(CGSize)size;
- (UIImage *)render:(NSInteger)number labelsAtSize:(CGSize)size;
- (UIImage *)renderBarsAtSize:(CGSize)size withNumberOfTicks:(NSInteger)ticks;
@end
