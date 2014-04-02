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
@property (strong, nonatomic) NSLayoutConstraint *labelWidth;
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
    if (self.chart) {
        [self redrawImagesForce:YES];
    }
}

- (void)setup
{
    [self addSubview:self.labelsView];
    [self addSubview:self.scrollView];
    self.labelsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"label": self.labelsView, @"chart": self.scrollView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label][chart]|"
                                                                options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    self.labelWidth = [NSLayoutConstraint constraintWithItem:self.labelsView
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:1
                                                    constant:21];
    
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

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.chartSize = self.bounds.size;
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

- (void)toggleZoom:(UITapGestureRecognizer *)sender
{
    CGPoint tapLocation = [sender locationInView:self];
    CGFloat scale = self.chartSize.width == self.originalSize.width ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
    [self.scrollView setZoomScale:scale animated:YES];
    [self.scrollView scrollRectToVisible:CGRectMake((tapLocation.x - CGRectGetWidth(self.bounds)/2) * scale,
                                                    0,
                                                    CGRectGetWidth(self.bounds),
                                                    CGRectGetHeight(self.bounds))
                                animated:YES];
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
    self.labelWidth.constant = labels.size.width;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self redrawImages];
    [self updateZoom];
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
}

@end
