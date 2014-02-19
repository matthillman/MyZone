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
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
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
    CGFloat ypad = !self.thumbnail ? 7/160.0f * size.height : 0;
    
    self.lengths = BarLengthsMake(minX, maxX, minY, maxY, xpad, ypad);
    
    CGSize drawingSize = size;
    drawingSize.width -= self.lengths.xPad;
    drawingSize.height -= self.lengths.yPad;
    
    return drawingSize;
}

- (void)draw:(NSInteger)number labelsInHeight:(CGFloat)height
{
    for (NSInteger i = 0; i <= number; ++i) {
        CGFloat y = (i * height / number) + self.lengths.yPad;
        [[UIColor lightGrayColor] setStroke];
        if (i < number) {
            NSString *label = [NSString stringWithFormat:@"%.0f", floor((10-i) * self.lengths.yLength / 10)];
            [label drawAtPoint:CGPointMake(3 + (5*(3-label.length)), y - self.lengths.xPad/3) withAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:self.lengths.xPad/2]}];
        }
    }
}

- (void)drawBarsInSize:(CGSize)size withNumberOfTicks:(NSInteger)ticks
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES];
    self.sorted = [self.points sortedArrayUsingDescriptors:@[descriptor]];
    
    CGFloat w = size.width / (CGFloat)self.sorted.count;
    
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
            size.width = (5 * self.sorted.count) + l.xPad;
        }
    }
    
    UIBezierPath *path;
    
    if (!self.thumbnail) {
        for (NSInteger i = 0; i <= ticks; ++i) {
            path = [UIBezierPath bezierPath];
            CGFloat y = (i * size.height / ticks) + l.yPad;
            [path moveToPoint:CGPointMake(l.xPad - 3, y)];
            [path addLineToPoint:CGPointMake(size.width + l.xPad, y)];
            [[UIColor lightGrayColor] setStroke];
            path.lineWidth = .5;
            [path stroke];
        }
    }
    
    for (GraphPoint *point in self.sorted) {
        NSInteger i = [self.sorted indexOfObject:point];
        CGPoint trans = CGPointMake(i * w,
                                    (size.height - ((point.point.y - l.yMin) / l.yLength * size.height)) + l.yPad);
        path = [UIBezierPath bezierPath];
        path.lineWidth = w > 5 ? 1 : .5;
        [path moveToPoint:CGPointMake(0, size.height + l.yPad)];
        [path addLineToPoint:CGPointMake(0, trans.y)];
        [path addLineToPoint:CGPointMake(w-path.lineWidth, trans.y)];
        [path addLineToPoint:CGPointMake(w-path.lineWidth, size.height + l.yPad)];
        [path closePath];
        
        UIColor *stroke = self.colors[point.category][@"stroke"] ?: [UIColor blackColor];
        UIColor *fill = self.colors[point.category][@"fill"] ?: [UIColor blackColor];
        
        [stroke setStroke];
        [fill setFill];
        
        CGContextRef old = UIGraphicsGetCurrentContext();
        CGContextSaveGState(old);
        
        CGContextTranslateCTM(old, trans.x + l.xPad + (path.lineWidth / 2), 0);
        
        [path stroke];
        [path fill];
        
        CGContextRestoreGState(old);
    }
}

@end
