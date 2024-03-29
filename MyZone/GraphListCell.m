//
//  GraphListCell.m
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "GraphListCell.h"
#import "BarChart.h"
#import "MZWorkout.h"
#import "MEPsLabel.h"
#import "EffortLabel.h"

@interface GraphListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet MEPsLabel *meps;
@property (weak, nonatomic) IBOutlet EffortLabel *effort;
@property (weak, nonatomic) IBOutlet UILabel *calories;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mepsTop;
@property (strong, nonatomic) CALayer *bottomBorder;
@end

@implementation GraphListCell

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

- (void)setup
{
    self.clipsToBounds = YES;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor lightGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, -1, 568.f + 2, CGRectGetHeight(self.frame));
    
    [self.layer addSublayer:bottomBorder];
    
    CALayer *bottomBorderClip = [CALayer layer];
    bottomBorderClip.borderColor = [UIColor whiteColor].CGColor;
    bottomBorderClip.borderWidth = 1;
    bottomBorderClip.frame = CGRectMake(-1, -1, 98.f + 1, CGRectGetHeight(self.frame));
    
    [self.layer addSublayer:bottomBorderClip];
}

- (void)configureForWorkout:(MZWorkout *)workout
{
    self.workout = workout;
    self.graphView.image = [self.workout workoutThumbnailGraphAtSize:self.graphView.bounds.size];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    NSDateFormatter *t = [[NSDateFormatter alloc] init];
    f.dateStyle = NSDateFormatterMediumStyle;
    t.timeStyle = NSDateFormatterShortStyle;
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.roundingMode = NSNumberFormatterRoundCeiling;
    nf.numberStyle = NSNumberFormatterDecimalStyle;
    self.titleLabel.text = workout.activity;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@ %@", [f stringFromDate:workout.start], [t stringFromDate:workout.start]];
    self.meps.MEPs = self.workout.meps;
    self.calories.text = [nf stringFromNumber:self.workout.calories];
    self.effort.averageEffort = self.workout.averageEffort;
    [self updateLayout:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.mepsTop.constant = 10;
    } else {
        self.mepsTop.constant = self.bounds.size.height + 10;
    }
    [self.effort setNeedsDisplay];
}

@end
