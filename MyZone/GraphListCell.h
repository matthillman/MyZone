//
//  GraphListCell.h
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MZWorkout, BarChart;

@interface GraphListCell : UICollectionViewCell
//move object is the model for this cell
@property (strong, nonatomic) MZWorkout *workout;
@property (strong, nonatomic) BarChart *grapher;
- (void)configureForWorkout:(MZWorkout *)workout;
@end
