//
//  Workout.h
//  MyZone
//
//  Created by Matthew Hillman on 4/4/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, Effort;

@interface Workout : NSManagedObject

@property (nonatomic, retain) NSString * averageEffort;
@property (nonatomic, retain) NSNumber * averageHeartRate;
@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSNumber * hrhIndex;
@property (nonatomic, retain) NSNumber * maxHeartRate;
@property (nonatomic, retain) NSNumber * meps;
@property (nonatomic, retain) NSNumber * mepsInZone1;
@property (nonatomic, retain) NSNumber * mepsInZone2;
@property (nonatomic, retain) NSNumber * mepsInZone3;
@property (nonatomic, retain) NSNumber * mepsInZone4;
@property (nonatomic, retain) NSNumber * mepsInZone5;
@property (nonatomic, retain) NSNumber * minutesInZone0;
@property (nonatomic, retain) NSNumber * minutesInZone1;
@property (nonatomic, retain) NSNumber * minutesInZone2;
@property (nonatomic, retain) NSNumber * minutesInZone3;
@property (nonatomic, retain) NSNumber * minutesInZone4;
@property (nonatomic, retain) NSNumber * minutesInZone5;
@property (nonatomic, retain) NSNumber * move;
@property (nonatomic, retain) NSNumber * numberOfMoves;
@property (nonatomic, retain) NSNumber * peakHeartRate;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSNumber * targetZoneMax;
@property (nonatomic, retain) NSString * targetZoneDuration;
@property (nonatomic, retain) NSString * totalDuration;
@property (nonatomic, retain) NSNumber * targetZoneMin;
@property (nonatomic, retain) NSString * activityName;
@property (nonatomic, retain) NSString * sectionTitle;
@property (nonatomic, retain) Activity *activity;
@property (nonatomic, retain) NSSet *effort;
@end

@interface Workout (CoreDataGeneratedAccessors)

- (void)addEffortObject:(Effort *)value;
- (void)removeEffortObject:(Effort *)value;
- (void)addEffort:(NSSet *)values;
- (void)removeEffort:(NSSet *)values;

@end
