//
//  MyZoneQuery.h
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MZEvent;

@interface MZQuery : NSObject
/**
 * Log in the given user
 *
 * @param user Username to use
 * @param password Password to use
 * @return YES if the login is successful, NO otherwise
 */
+ (BOOL)loginUser:(NSString *)user password:(NSString *)password;

/**
 * Check if a user is logged in already
 *
 * @return YES if a user is logged in
 */
+ (BOOL)isLoggedIn;

/**
 * Gets the profile for the logged in user.
 *
 * Must have called loginUser and have a valid login session
 * @return User Profile Dictionaary
 */
+ (void)getUserProfileWithCompletionHandler:(void (^)(NSDictionary *results))completion;
/**
 * Gets the events in the given date range.
 *
 * Must have called loginUser and have a valid login session
 * @param start Start date of range
 * @param end End date of range
 * @return NSArray of MZEvent * objects
 */
+ (void)getUserEventsFrom:(NSDate *)start to:(NSDate *)end completionHandler:(void (^)(NSArray *events))completion;
/**
 * Gets the workouts in the given event's dates. Uses the start and end properties of the event to create the date range.
 *
 * Must have called loginUser and have a valid login session
 * @param event MZEvent to use for the query
 * @return NSArray of MZWorkout in the time frame
 */
+ (void)getUserWorkoutsForEvent:(MZEvent *)event completionHandler:(void (^)(NSArray *workouts))completion;
/**
 * Gets the workouts in the given date range. Only the day, month and year portion of the dates are used.
 *
 * Must have called loginUser and have a valid login session
 * @param start Start date of range
 * @param end End date of range
 * @return NSArray of MZWorkout in the time frame
 */
+ (void)getUserWorkoutsFrom:(NSDate *)start to:(NSDate *)end completionHandler:(void (^)(NSArray *workouts))completion;
@end
