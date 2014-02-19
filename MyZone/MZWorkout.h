//
//  MZWorkout.h
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZDefs.h"

@class BarChart;

@interface MZWorkout : NSObject
/**
 * Activity done during workout
 */
@property (strong, nonatomic) NSString *activity;
/**
 * Average heart rate percent over the workout. Stored as string includig %.
 */
@property (strong, nonatomic) NSString *averageEffort;
/**
 * Average heart rate BPM over the workout
 */
@property (strong, nonatomic) NSNumber *averageHeartRate;
/**
 * Peak heart rate recorded during the workout
 */
@property (strong, nonatomic) NSNumber *peakHeartRate;
/**
 * Max Heart rate BPM of the User
 */
@property (strong, nonatomic) NSNumber *maxHeartRate;
/**
 * Total number of Calories burned during the workout
 */
@property (strong, nonatomic) NSNumber *calories;
/**
 * Number of minutes in zone 0
 */
@property (strong, nonatomic) NSNumber *minutesInZone0;
/**
 * Number of minutes in zone 1
 */
@property (strong, nonatomic) NSNumber *minutesInZone1;
/**
 * Number of minutes in zone 2
 */
@property (strong, nonatomic) NSNumber *minutesInZone2;
/**
 * Number of minutes in zone 3
 */
@property (strong, nonatomic) NSNumber *minutesInZone3;
/**
 * Number of minutes in zone 4
 */
@property (strong, nonatomic) NSNumber *minutesInZone4;
/**
 * Number of minutes in zone 5
 */
@property (strong, nonatomic) NSNumber *minutesInZone5;
/**
 * NSArray of MZPoint items representing all effort points in the workout
 */
@property (readonly, nonatomic) NSArray *effort;
/**
 * NSArray of GraphPont items representing all effort points in the workout
 */
@property (readonly, nonatomic) NSArray *graphPoints;
/**
 * NSArray of MZPoint items representing the data points spent in zone 0
 */
@property (strong, nonatomic) NSArray *effortInZone0;
/**
 * NSArray of MZPoint items representing the data points spent in zone 1
 */
@property (strong, nonatomic) NSArray *effortInZone1;
/**
 * NSArray of MZPoint items representing the data points spent in zone 2
 */
@property (strong, nonatomic) NSArray *effortInZone2;
/**
 * NSArray of MZPoint items representing the data points spent in zone 3
 */
@property (strong, nonatomic) NSArray *effortInZone3;
/**
 * NSArray of MZPoint items representing the data points spent in zone 4
 */
@property (strong, nonatomic) NSArray *effortInZone4;
/**
 * NSArray of MZPoint items representing the data points spent in zone 5
 */
@property (strong, nonatomic) NSArray *effortInZone5;
/**
 * End date of workout
 */
@property (strong, nonatomic) NSDate *end;
/**
 * Start date of workout
 */
@property (strong, nonatomic) NSDate *start;
/**
 * Where this workout falls in numberOfMoves
 */
@property (strong, nonatomic) NSNumber *move;
/**
 * Number of moves in workout
 */
@property (strong, nonatomic) NSNumber *numberOfMoves;
/**
 * Total number of MEPs earned during workout
 */
@property (strong, nonatomic) NSNumber *meps;
/**
 * Number of MEPs earned in zone 1 during the workout
 */
@property (strong, nonatomic) NSNumber *mepsInZone1;
/**
 * Number of MEPs earned in zone 2 during the workout
 */
@property (strong, nonatomic) NSNumber *mepsInZone2;
/**
 * Number of MEPs earned in zone 3 during the workout
 */
@property (strong, nonatomic) NSNumber *mepsInZone3;
/**
 * Number of MEPs earned in zone 4 during the workout
 */
@property (strong, nonatomic) NSNumber *mepsInZone4;
/**
 * Number of MEPs earned in zone 5 during the workout
 */
@property (strong, nonatomic) NSNumber *mepsInZone5;
/**
 * Rage that is the target zone. Min and Max are percentages of max heart rate stored as NSUIntegers
 */
@property (assign, nonatomic) TZRange targetZone;
/**
 * Time spent with the heart rate in the range specified in targetZone. Stored as a string HH:mm
 */
@property (strong, nonatomic) NSString *targetZoneDuration;
/**
 * Total time of the move Stored as a string HH:mm
 */
@property (strong, nonatomic) NSString *totalDuration;

@property (strong, nonatomic, readonly) BarChart *grapher;


- (UIImage *)workoutGraphAtSize:(CGSize)size;
- (UIImage *)workoutThumbnailGraphAtSize:(CGSize)size;
- (UIImage *)workoutGraphFullWidthAtSize:(CGSize)size;
- (NSArray *)detailViews;

+ (NSArray *)workoutsForJSONWorkoutDictionary:(NSDictionary *)jsonWorkout;
@end
