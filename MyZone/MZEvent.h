//
//  MZEvent.h
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZDefs.h"

@interface MZEvent : NSObject
/**
 * Display title
 */
@property (strong, nonatomic) NSString *title;
/**
 * Belt SN
 */
@property (strong, nonatomic) NSNumber *belt;
/**
 * Event start date
 */
@property (strong, nonatomic) NSDate *start;
/**
 * Event end date
 */
@property (strong, nonatomic) NSDate *end;
/**
 * Maximum heart rate of user at time of event. This is not the maximum heart rate achieved during the event, which is in the peakheartRate property.
 */
@property (strong, nonatomic) NSNumber *maximumHeartRate;
/**
 * Rage that is the target zone. Min and Max are percentages of max heart rate stored as NSUIntegers
 */
@property (assign, nonatomic) TZRange targetZone;
/**
 * Duration of the event, in minutes
 */
@property (strong, nonatomic) NSNumber *duration;
/**
 * Number of moves the event
 */
@property (strong, nonatomic) NSNumber *moves;

/**
 * Average effort.
 * 
 * This is a percentage.
 */
@property (strong, nonatomic) NSNumber *averageEffort;
/**
 * Average heart rate during the event
 */
@property (strong, nonatomic) NSNumber *averageHeartRate;
/**
 * Peak heart rate recorded during the event
 */
@property (strong, nonatomic) NSNumber *peakHeartRate;
/**
 * Calories burned during the event
 */
@property (strong, nonatomic) NSNumber *calories;


/**
 * Total number of MEPs recorded in the event
 */
@property (strong, nonatomic) NSNumber *meps;
/**
 * Total number of MEPs in Zone 1 recorded in the event
 */
@property (strong, nonatomic) NSNumber *mepsInZone1;
/**
 * Total number of MEPs in Zone 2 recorded in the event
 */
@property (strong, nonatomic) NSNumber *mepsInZone2;
/**
 * Total number of MEPs in Zone 3 recorded in the event
 */
@property (strong, nonatomic) NSNumber *mepsInZone3;
/**
 * Total number of MEPs in Zone 4 recorded in the event
 */
@property (strong, nonatomic) NSNumber *mepsInZone4;
/**
 * Total number of MEPs in Zone 5 recorded in the event
 */
@property (strong, nonatomic) NSNumber *mepsInZone5;

/**
 * Total number of minutes in the target zone
 */
@property (strong, nonatomic) NSNumber *minutesInTargetZone;
/**
 * Total number of minutes in target zone 0
 */
@property (strong, nonatomic) NSNumber *minutesInZone0;
/**
 * Total number of minutes in target zone 1
 */
@property (strong, nonatomic) NSNumber *minutesInZone1;
/**
 * Total number of minutes in target zone 2
 */
@property (strong, nonatomic) NSNumber *minutesInZone2;
/**
 * Total number of minutes in target zone 3
 */
@property (strong, nonatomic) NSNumber *minutesInZone3;
/**
 * Total number of minutes in target zone 4
 */
@property (strong, nonatomic) NSNumber *minutesInZone4;
/**
 * Total number of minutes in target zone 5
 */
@property (strong, nonatomic) NSNumber *minutesInZone5;

+ (MZEvent *)eventForJSONEventDictionary:(NSDictionary *)jsonEvent;
@end
