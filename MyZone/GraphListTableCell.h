//
//  GraphListTableCell.h
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZWorkout, BarChart;

@interface GraphListTableCell : UITableViewCell
@property (strong, nonatomic) MZWorkout *workout;
@property (strong, nonatomic) BarChart *grapher;

- (void)configureForWorkout:(MZWorkout *)workout;
- (void)updateLayout:(UIInterfaceOrientation)orientation;
@end
