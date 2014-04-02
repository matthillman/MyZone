//
//  WorkoutHeading.h
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZWorkout;

@interface WorkoutHeading : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *tzLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxHrLabel;

- (void)configureWithDate:(NSDate *)date
               moveNumber:(NSNumber *)move
                       of:(NSNumber *)totalMoves
               targetZone:(TZRange)zone
                    maxHr:(NSNumber *)max
                 duration:(NSString *)duration;

- (void)configureWithWorkout:(MZWorkout *)workout;
@end
