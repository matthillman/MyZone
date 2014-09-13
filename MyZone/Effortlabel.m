//
//  MEPsView.m
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "EffortLabel.h"
#import "UIBezierPath+IOS7RoundedRect.h"
#import "MZQuery.h"

@interface EffortLabel ()
@property (strong, nonatomic) UILabel *text;
@property (assign, nonatomic) MZZoneKey zone;
@property (assign, nonatomic) CGRect drawingFrame;
@end

@implementation EffortLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    [self setup];
    return self;
}

- (void)setup
{
    CGFloat w = MIN(1.5 * CGRectGetHeight(self.frame), CGRectGetWidth(self.frame)-2);
    CGFloat x = (CGRectGetWidth(self.frame) - w) / 2.0f * 1.1;
    LogDebug(@"View width is %@", CGRectGetWidth(self.frame));
    LogDebug(@"Drawing frame width is %@", w);
    self.drawingFrame = CGRectMake(x, 2, w, CGRectGetHeight(self.frame)-4);
    self.text.frame = UIEdgeInsetsInsetRect(self.drawingFrame, UIEdgeInsetsMake(3, 3, 3, 3));
    self.text.textColor = [UIColor whiteColor];
    self.text.textAlignment = NSTextAlignmentCenter;
    self.text.font = [UIFont fontWithName:@"AvenirNext-Bold" size:17];
    self.text.adjustsFontSizeToFitWidth = YES;
    if (!self.averageEffort) {
        self.text.text = @"%";
    }
    [self addSubview:self.text];
    [self bringSubviewToFront:self.text];
    self.text.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-3-[lab]-3-|" options:0 metrics:nil views:@{@"lab": self.text}]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[lab]-3-|" options:0 metrics:nil views:@{@"lab": self.text}]];
    
    UIView *superview = self;
    UILabel *label = self.text;
    NSDictionary *variables = NSDictionaryOfVariableBindings(label, superview);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=1)-[label]"
                                                                   options:NSLayoutFormatAlignAllCenterX
                                                                   metrics:nil
                                                                     views:variables];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[superview]-(<=1)-[label]"
                                                          options:NSLayoutFormatAlignAllCenterY
                                                          metrics:nil
                                                            views:variables];
    [self addConstraints:constraints];
    
    [self.text sizeToFont];
    self.text.textAlignment = NSTextAlignmentCenter;
}

- (UILabel *)text
{
    if (!_text) _text = [[UILabel alloc] init];
    return _text;
}

- (void)setAverageEffort:(NSString *)averageEffort
{
    _averageEffort = averageEffort;
    NSMutableParagraphStyle *p = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    p.alignment = NSTextAlignmentCenter;
    self.text.attributedText = [[NSAttributedString alloc] initWithString:self.averageEffort attributes:@{NSFontAttributeName: self.text.font,
                                                                                                          NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                          NSStrokeColorAttributeName: [UIColor blackColor],
                                                                                                          NSStrokeWidthAttributeName: @(-4),
                                                                                                          NSParagraphStyleAttributeName: p}];
    self.zone = [MZQuery zoneForAverageEffort:self.averageEffort];
    [self.text sizeToFont];
}

-(void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithIOS7RoundedRect:self.drawingFrame cornerRadius:MIN(CGRectGetHeight(self.drawingFrame), CGRectGetWidth(self.drawingFrame))/6.0f];
    [[UIColor blackColor] setStroke];
    [[UIColor fillColorForZone:self.zone] setFill];
    [path fill];
    path.lineWidth = 1;
    [path stroke];
}

@end
