//
//  Workout+MZ.h
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "Workout.h"

@interface Workout (MZ)
@property (readonly, nonatomic) TZRange targetZone;

+ (NSArray *)workoutsForJSONWorkoutDictionary:(NSDictionary *)jsonWorkout inContext:(NSManagedObjectContext *)context;
- (UIImage *)workoutGraphAtSize:(CGSize)size;
- (UIImage *)workoutThumbnailGraphAtSize:(CGSize)size;
- (UIImage *)workoutGraphFullWidthAtSize:(CGSize)size;
- (NSArray *)graphPoints;
- (NSArray *)detailViews;

@end
