//
//  ScrollingChartView.m
//  MyZone
//
//  Created by Matthew Hillman on 2/19/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "ScrollingChartView.h"
#import "BarChart.h"
#import "HorizontalScalingView.h"

@interface ScrollingChartView () <UIScrollViewDelegate>
@property (strong, nonatomic) BarChart *grapher;
@property (strong, nonatomic) UIImage *labels;
@property (strong, nonatomic) UIImageView *labelsView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) HorizontalScalingView *imageView;
@property (strong, nonatomic) UIImage *chart;
@property (assign, nonatomic) CGSize chartSize;
@property (readonly, nonatomic) CGSize originalSize;
@end

@implementation ScrollingChartView

- (id)init
{
    if (!(self = [super init])) return nil;
    [self setup];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    [self setup];
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self redrawImagesForce:YES];
}

- (void)setup
{
    self.chartSize = self.bounds.size;
    [self addSubview:self.labelsView];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.scrollView.bouncesZoom = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.delegate = self;
    [self updateZoom];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleZoom:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fireTargetAction:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer requireGestureRecognizerToFail: doubleTapGestureRecognizer];
    [self addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)redrawImages
{
    [self redrawImagesForce:NO];
}

- (void)redrawImagesForce:(BOOL)labels
{
    if (!self.labels || labels) {
        self.labels = [self.grapher render:10 labelsAtSize:self.bounds.size];
        self.chartSize = self.originalSize;
    }
    
    self.chart = [self.grapher renderBarsAtSize:self.chartSize withNumberOfTicks:10];
}

- (CGSize)originalSize
{
    return CGSizeMake(self.bounds.size.width - self.labels.size.width, self.bounds.size.height);
}

- (void)updateZoom
{
    CGFloat maxWidth = MAX(10 * self.grapher.points.count, self.originalSize.width);
    self.scrollView.maximumZoomScale = maxWidth / self.chartSize.width;
    
    CGFloat minWidth = self.originalSize.width;
    self.scrollView.minimumZoomScale = minWidth / self.chartSize.width;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.chartSize = CGSizeMake(MAX(self.originalSize.width * scale, self.originalSize.width), self.originalSize.height);
    CGFloat x = self.scrollView.contentOffset.x / self.scrollView.contentSize.width;
    [self redrawImages];
    self.scrollView.zoomScale = 1;
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = x * self.scrollView.contentSize.width;
    self.scrollView.contentOffset = offset;
}

- (void)toggleZoom:(id)sender
{
    CGFloat scale = self.chartSize.width == self.originalSize.width ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
    [self.scrollView setZoomScale:scale animated:YES];
}

- (void)fireTargetAction:(id)sender
{
    IMP imp = [self.target methodForSelector:self.action];
    void (*func)(id, SEL) = (void *)imp;
    func(self.target, self.action);
}

- (BarChart *)grapher
{
    if (!_grapher) {
        _grapher = [[BarChart alloc] init];
        _grapher.average = YES;
        _grapher.thumbnail = NO;
        _grapher.yRange = NSMakeRange(0, 100);
    }
    return _grapher;
}

- (NSArray *)points
{
    return self.grapher.points;
}

- (void)setPoints:(NSArray *)points
{
    self.grapher.points = points;
    self.chartSize = self.originalSize;
    [self redrawImagesForce:YES];
    [self updateZoom];
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (NSDictionary *)colors
{
    return self.grapher.colors;
}

- (void)setColors:(NSDictionary *)colors
{
    self.grapher.colors = colors;
    
    if (self.chart) {
        [self redrawImages];
    }
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) _scrollView = [[UIScrollView alloc] init];
    return  _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[HorizontalScalingView alloc] init];
    return _imageView;
}

- (UIImage *)chart
{
    return self.imageView.image;
}

- (void)setChart:(UIImage *)image
{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.chart ? self.chart.size : CGSizeZero;
    CGRect newFrame = self.imageView.frame;
    newFrame.origin = CGPointZero;
    self.imageView.frame = newFrame;
    [self updateZoom];
}

- (UIImageView *)labelsView
{
    if (!_labelsView) _labelsView = [[UIImageView alloc] init];
    return _labelsView;
}

- (UIImage *)labels
{
    return self.labelsView.image;
}

- (void)setLabels:(UIImage *)labels
{
    self.labelsView.image = labels;
    self.labelsView.frame = CGRectMake(0, 0, labels.size.width, CGRectGetHeight(self.bounds));
    self.scrollView.frame = CGRectMake(CGRectGetWidth(self.labelsView.frame), 0,
                                       CGRectGetWidth(self.bounds) - CGRectGetWidth(self.labelsView.frame), CGRectGetHeight(self.bounds));
}

@end
