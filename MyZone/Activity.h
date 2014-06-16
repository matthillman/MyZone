//
//  Activity.h
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Workout;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSSet *workout;
@end

@interface Activity (CoreDataGeneratedAccessors)

- (void)addWorkoutObject:(Workout *)value;
- (void)removeWorkoutObject:(Workout *)value;
- (void)addWorkout:(NSSet *)values;
- (void)removeWorkout:(NSSet *)values;

@end
