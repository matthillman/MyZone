//
//  GraphCellBase.m
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "GraphListTableCell.h"
#import "BarChart.h"
#import "Workout+MZ.h"
#import "MEPsLabel.h"
#import "EffortLabel.h"
#import "Activity.h"

@interface GraphListTableCell ()
@property (weak, nonatomic) IBOutlet UIImageView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet MEPsLabel *meps;
@property (weak, nonatomic) IBOutlet EffortLabel *effort;
@property (weak, nonatomic) IBOutlet UILabel *calories;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mepsTop;
@end

@implementation GraphListTableCell

- (void)configureForWorkout:(Workout *)workout
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
    self.titleLabel.text = workout.activityName;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@ %@", [f stringFromDate:workout.start], [t stringFromDate:workout.start]];
    self.meps.MEPs = self.workout.meps;
    self.calories.text = [nf stringFromNumber:self.workout.calories];
    self.effort.averageEffort = self.workout.averageEffort;
    [self updateLayout:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.mepsTop.constant = 11;
    } else {
        self.mepsTop.constant = self.bounds.size.height + 11;
    }
    [self.effort setNeedsDisplay];
}
@end
