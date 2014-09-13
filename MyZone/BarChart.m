//
//  BarChartView.m
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "BarChart.h"
#import "GraphPoint.h"

typedef struct _BarLengths {
    CGFloat xMin;
    CGFloat xMax;
    CGFloat yMin;
    CGFloat yMax;
    CGFloat xLength;
    CGFloat yLength;
    CGFloat xPad;
    CGFloat yPad;
} BarLengths;

NS_INLINE BarLengths BarLengthsMake(CGFloat xMin, CGFloat xMax, CGFloat yMin, CGFloat yMax, CGFloat xPad, CGFloat yPad) {
    BarLengths l;
    l.xMin = xMin;
    l.xMax = xMax;
    l.yMin = yMin;
    l.yMax = yMax;
    l.xLength = xMax - xMin;
    l.yLength = yMax - yMin;
    l.xPad = xPad;
    l.yPad = yPad;
    return l;
}

@interface BarChart ()
@property (strong, nonatomic) NSArray *sorted;
@property (assign, nonatomic) BarLengths lengths;
@property (strong, nonatomic) NSDictionary *attributes;
@end

@implementation BarChart

- (id)init
{
    if (!(self = [super init])) return nil;
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self init];
}

- (void)setup
{
    self.xRange = NSMakeRange(NSNotFound, 0);
    self.yRange = NSMakeRange(NSNotFound, 0);
}

- (void)setPoints:(NSArray *)points
{
    _points = points;
}

- (UIImage *)renderImgaeAtSize:(CGSize)size
{
    CGSize drawingSize = [self setupLengthsInSize:size];
    CGSize imageSize = drawingSize;
    imageSize.height += self.lengths.yPad;
    imageSize.width += self.lengths.xPad;
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    [self drawBarsInSize:drawingSize withNumberOfTicks:10];
    
    if (!self.thumbnail) {
        [self draw:10 labelsInHeight:drawingSize.height];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsPopContext();
    
    return image;
}

- (UIImage *)render:(NSInteger)number labelsAtSize:(CGSize)size
{
    CGSize drawingSize = [self setupLengthsInSize:size];
    CGSize imageSize = size;
    imageSize.width = self.lengths.xPad;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    [self draw:number labelsInHeight:drawingSize.height];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsPopContext();
    
    return image;
}

- (UIImage *)renderBarsAtSize:(CGSize)size withNumberOfTicks:(NSInteger)ticks
{
    CGSize drawingSize = [self setupLengthsInSize:size];
    BarLengths l = self.lengths;
    l.xPad = 3;
    self.lengths = l;
    drawingSize.width = size.width - l.xPad;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [self drawBarsInSize:drawingSize withNumberOfTicks:ticks];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsPopContext();
    
    return image;
}

- (CGSize)setupLengthsInSize:(CGSize)size
{
    // find min and max in the ranges of the data
    CGFloat minX = FLT_MAX, maxX = 0, minY = FLT_MAX, maxY = 0;
    if (self.xRange.location == NSNotFound) {
        for (GraphPoint *point in self.points) {
            if (point.point.x > maxX) maxX = point.point.x;
            if (point.point.x < minX) minX = point.point.x;
        }
    } else {
        minX = self.xRange.location;
        maxX = self.xRange.location + self.xRange.length;
    }
    
    if (self.yRange.location == NSNotFound) {
        for (GraphPoint *point in self.points) {
            if (point.point.y > maxY) maxY = point.point.y;
            if (point.point.y < minY) minY = point.point.y;
        }
    } else {
        minY = self.yRange.location;
        maxY = self.yRange.location + self.yRange.length;
    }
    
    CGFloat xpad = !self.thumbnail ? 21/320.0f * size.width : 0;
    CGFloat ypad = !self.thumbnail ? 10/160.0f * size.height : 0;
    
    self.lengths = BarLengthsMake(minX, maxX, minY, maxY, xpad, ypad);
    self.attributes = @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:ypad]};
    
    CGSize drawingSize = size;
    drawingSize.width -= self.lengths.xPad;
    drawingSize.height -= self.lengths.yPad;
    
    if ((size.width / (CGFloat)self.points.count) < 5 && !self.thumbnail && !self.average) {
        drawingSize.width = 5 * self.points.count;
    }
    
    return drawingSize;
}

- (void)draw:(NSInteger)number labelsInHeight:(CGFloat)height
{
    NSString *label;
    CGFloat y;
    [[UIColor lightGrayColor] setStroke];
    for (NSInteger i = 0; i <= number; ++i) {
        y = (i * (height - self.lengths.yPad * 2) / number) + self.lengths.yPad;
        if (i < number) {
            label = [NSString stringWithFormat:@"%.0f", floor((10-i) * self.lengths.yLength / 10)];
            [label drawAtPoint:CGPointMake(3 + (5*(3-label.length)), y - self.lengths.xPad/3) withAttributes:self.attributes];
        }
    }
}

- (void)drawBarsInSize:(CGSize)size withNumberOfTicks:(NSInteger)ticks
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES];
    self.sorted = [self.points sortedArrayUsingDescriptors:@[descriptor]];
    
    CGFloat w = size.width / (CGFloat)self.sorted.count;
    
    CGFloat x0 = self.lengths.xMin, xf = self.lengths.xMax;
    
    BarLengths l = self.lengths;
    // shirink the dataset if we're making a thumbnail and we need to
    if (w < 5) {
        if ((self.average || self.thumbnail)) {
            NSInteger idealCount = floor(size.width / 5);
            CGFloat step = l.xLength / idealCount;
            
            NSMutableDictionary *buckets = [[NSMutableDictionary alloc] initWithCapacity:idealCount];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            for (GraphPoint *p in self.sorted) {
                NSNumber *bucket = [NSNumber numberWithInteger:floor((p.point.x - l.xMin) / step)];
                if (!buckets[bucket]) buckets[bucket] = [@[] mutableCopy];
                [(NSMutableArray *)buckets[bucket] addObject:@{@"y": [NSNumber numberWithFloat:p.y], @"cat": [f numberFromString:p.category]}];
            }
            
            NSMutableArray *banded = [[NSMutableArray alloc] initWithCapacity:idealCount];
            for (NSNumber *bucket in buckets) {
                [banded addObject:[[GraphPoint alloc] initWithPoint:CGPointMake([bucket integerValue], [[buckets[bucket] valueForKeyPath:@"y.@avg.self"] floatValue])
                                                           category:[NSString stringWithFormat:@"%ld", (long)[[buckets[bucket] valueForKeyPath:@"cat.@avg.self"] integerValue]]]];
            }
            
            l.xLength = banded.count;
            l.xMin = 0;
            l.xMax = l.xLength - 1;
            self.sorted = [banded sortedArrayUsingDescriptors:@[descriptor]];
            w = size.width / (CGFloat)self.sorted.count;
        } else {
            w = 5;
            size.width = 5 * self.sorted.count;
        }
    }
    
    UIBezierPath *path;
    
    if (!self.thumbnail) {
        for (NSInteger i = 0; i <= ticks; ++i) {
            path = [UIBezierPath bezierPath];
            CGFloat y = (i * (size.height - l.yPad * 2) / ticks) + l.yPad;
            [path moveToPoint:CGPointMake(l.xPad - 3, y)];
            [path addLineToPoint:CGPointMake(size.width + l.xPad, y)];
            [[UIColor lightGrayColor] setStroke];
            path.lineWidth = .5;
            [path stroke];
        }
        
        NSDate *d0 = [NSDate dateWithTimeIntervalSince1970:x0];
        NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;// | NSSecondCalendarUnit;
        NSDateComponents *tickComponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:d0];
        NSDateComponents *fiveMinTickComponents = [tickComponents copy];
        NSDateComponents *labelComponents = [tickComponents copy];
        fiveMinTickComponents.minute = ceil((float) tickComponents.minute / 5.0) * 5.0;
        
        NSDate *firstTick = [[NSCalendar currentCalendar] dateFromComponents:tickComponents];
        NSDate *firstFiveMinTick = [[NSCalendar currentCalendar] dateFromComponents:fiveMinTickComponents];
        
        labelComponents.minute = ceil((float) labelComponents.minute / 15.0) * 15.0;
        NSDate *firstLabel = [[NSCalendar currentCalendar] dateFromComponents:labelComponents];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"HH:mm";
        dateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        
        // Draw minute ticks with dark ticks every five minutes and labels every 15
        CGFloat oneMin = 60;
        CGFloat tickSpacing = self.average ? oneMin / (xf - x0) * (size.width - l.xPad) : w;
        CGFloat yTop = size.height - l.yPad;
        NSInteger xTicks = ceil((xf - x0) / oneMin);
        CGFloat offset = [firstTick timeIntervalSinceDate:d0] / (xf - x0) * (size.width - l.xPad);
        NSInteger labelOffset = floor([firstLabel timeIntervalSinceDate:firstTick] / oneMin);
        NSInteger fiveMinTickOffset = floor([firstFiveMinTick timeIntervalSinceDate:firstTick] / oneMin);
        NSString *label;
        CGFloat x;
        
        for (NSInteger i = 0; i <= xTicks; ++i) {
            path = [UIBezierPath bezierPath];
            x = (i * tickSpacing) + l.xPad + offset;
            [path moveToPoint:CGPointMake(x, yTop)];
            
            if (i % 15 == labelOffset) {
                [[UIColor blackColor] setStroke];
                path.lineWidth = 1;
                [path addLineToPoint:CGPointMake(x, yTop + l.yPad/3)];
                labelComponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:[NSDate dateWithTimeInterval:i * oneMin sinceDate:d0]];
                labelComponents.minute = ceil((float) labelComponents.minute / 15.0) * 15.0;
                label = [dateFormat stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:labelComponents]];
                [label drawAtPoint:CGPointMake(x - [(UIFont *)self.attributes[NSFontAttributeName] pointSize], yTop) withAttributes:self.attributes];
            } else if (i % 5 == fiveMinTickOffset) {
                [[UIColor blackColor] setStroke];
                path.lineWidth = 1;
                [path addLineToPoint:CGPointMake(x, yTop + l.yPad/2)];
            } else {
                [[UIColor lightGrayColor] setStroke];
                path.lineWidth = .5;
                [path addLineToPoint:CGPointMake(x, yTop + l.yPad/4)];
            }
            [path stroke];
        }
    }
    
    for (GraphPoint *point in self.sorted) {
        NSInteger i = [self.sorted indexOfObject:point];
        path = [UIBezierPath bezierPath];
        path.lineWidth = w > 5 ? 1 : .5;
        CGPoint trans = CGPointMake(i * w,
                                    (size.height - ((point.point.y - l.yMin) / l.yLength * (size.height - l.yPad * 2))) - l.yPad);
        [path moveToPoint:CGPointMake(0, size.height - l.yPad)];
        [path addLineToPoint:CGPointMake(0, trans.y)];
        [path addLineToPoint:CGPointMake(w-path.lineWidth, trans.y)];
        [path addLineToPoint:CGPointMake(w-path.lineWidth, size.height - l.yPad)];
        [path closePath];
        
        UIColor *stroke = self.colors[point.category][@"stroke"] ?: [UIColor blackColor];
        UIColor *fill = self.colors[point.category][@"fill"] ?: [UIColor blackColor];
        
        [stroke setStroke];
        [fill setFill];
        
        CGContextRef old = UIGraphicsGetCurrentContext();
        CGContextSaveGState(old);
        
        CGContextTranslateCTM(old, trans.x + l.xPad, 0);
        
        [path stroke];
        [path fill];
        
        CGContextRestoreGState(old);
    }
}

@end
