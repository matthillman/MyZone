//
//  MEPsView.m
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "MEPsLabel.h"

@interface MEPsLabel ()
@property (assign, nonatomic) CGRect drawingFrame;
@property (strong, nonatomic) UILabel *text;
@end

@implementation MEPsLabel

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
    self.drawingFrame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, 0, 5));
    self.text.frame = UIEdgeInsetsInsetRect(self.drawingFrame, UIEdgeInsetsMake(0, CGRectGetHeight(self.drawingFrame), 0, CGRectGetHeight(self.drawingFrame)/4));
    self.text.textColor = [UIColor whiteColor];
    self.text.textAlignment = NSTextAlignmentRight;
    self.text.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    self.text.adjustsFontSizeToFitWidth = YES;
    if (!self.MEPs) {
        self.text.text = @"MEPs";
    }
    [self.text sizeToFont];
    [self addSubview:self.text];
    [self bringSubviewToFront:self.text];
}

- (UILabel *)text
{
    if (!_text) _text = [[UILabel alloc] init];
    return _text;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setup];
}

- (void)setMEPs:(NSNumber *)MEPs
{
    _MEPs = MEPs;
    self.text.text = [self.MEPs integerValue] > 0 ? [NSString stringWithFormat:@"%d", [self.MEPs integerValue]] : @"N/A";
    [self.text sizeToFont];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setup];
}

- (void)drawRect:(CGRect)rect
{
    CGSize s = CGSizeMake(CGRectGetHeight(self.drawingFrame)/2, CGRectGetHeight(self.drawingFrame)/2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.drawingFrame byRoundingCorners:UIRectCornerAllCorners cornerRadii:s];
    [[UIColor blackColor] setFill];
    [path fill];
    
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(s.height, s.height) radius:s.height startAngle:0 endAngle:2*M_PI clockwise:YES];
    [self.backgroundColor setStroke];
    path.lineWidth = 1.5;
    [path stroke];
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    CGFloat a = 2 * s.height;
    [line moveToPoint:CGPointMake(0, a)];
    [line addLineToPoint:CGPointMake(a * 0.25f, a * 0.45f)];
    [line addLineToPoint:CGPointMake(a * 0.35f, a * 0.619f)];
    [line addLineToPoint:CGPointMake(a * 0.47f, a * 0.3f)];
    [line addLineToPoint:CGPointMake(a * 0.59f, a * 0.619f)];
    [line addLineToPoint:CGPointMake(a, a * 0.619f)];
    
    [path addClip];
    line.lineWidth = 3.5;
    line.lineJoinStyle = kCGLineJoinRound;
    [[UIColor whiteColor] setStroke];
    [line stroke];
}

@end
