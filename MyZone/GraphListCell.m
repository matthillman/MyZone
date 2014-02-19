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

@interface GraphListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@end

@implementation GraphListCell

- (void)configureForWorkout:(MZWorkout *)workout
{
    self.workout = workout;
    self.graphView.image = [self.workout workoutThumbnailGraphAtSize:self.graphView.bounds.size];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    NSDateFormatter *t = [[NSDateFormatter alloc] init];
    f.dateStyle = NSDateFormatterMediumStyle;
    t.timeStyle = NSDateFormatterShortStyle;
    self.titleLabel.text = workout.activity;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@ %@", [f stringFromDate:workout.start], [t stringFromDate:workout.start]];
}

@end
