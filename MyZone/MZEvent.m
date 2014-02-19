//
//  MZEvent.m
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "MZEvent.h"
#import "MZQuery.h"

@interface MZEvent ()
// storage for properties in the JSON Dictionary that are used private to calculate putblicly visible properties
@property (strong, nonatomic) NSNumber *targetZoneMax;
@property (strong, nonatomic) NSNumber *targetZoneMin;
@property (strong, nonatomic) NSString *startString;
@property (strong, nonatomic) NSString *startTimeString;
@property (strong, nonatomic) NSString *endTimeString;

/**
 * Not sure what this is
 */
@property (strong, nonatomic) NSNumber *dst;

@end

@implementation MZEvent

+ (MZEvent *)eventForJSONEventDictionary:(NSDictionary *)jsonEvent
{
    MZEvent *event = [[MZEvent alloc] init];
    
    event.averageEffort = jsonEvent[@"aveEffort"];
    event.averageHeartRate = jsonEvent[@"aveHr"];
    event.belt = jsonEvent[@"belt"];
    event.calories = jsonEvent[@"calories"];
    event.dst = jsonEvent[@"dst"];
    event.duration = jsonEvent[@"duration"];
    event.endTimeString = jsonEvent[@"endTime"];
    event.maximumHeartRate = jsonEvent[@"maxHR"];
    event.moves = jsonEvent[@"moves"];
    event.peakHeartRate = jsonEvent[@"peakHR"];
    event.meps = jsonEvent[@"points"];
    event.mepsInZone1 = jsonEvent[@"points1"];
    event.mepsInZone2 = jsonEvent[@"points2"];
    event.mepsInZone3 = jsonEvent[@"points3"];
    event.mepsInZone4 = jsonEvent[@"points4"];
    event.mepsInZone5 = jsonEvent[@"points5"];
    event.startString = jsonEvent[@"start"];
    event.startTimeString = jsonEvent[@"startTime"];
    event.title = jsonEvent[@"title"];
    event.minutesInTargetZone = jsonEvent[@"tzDuration"];
    event.targetZoneMax = jsonEvent[@"tzMax"];
    event.targetZoneMin = jsonEvent[@"tzMin"];
    event.minutesInZone0 = jsonEvent[@"zone0"];
    event.minutesInZone1 = jsonEvent[@"zone1"];
    event.minutesInZone2 = jsonEvent[@"zone2"];
    event.minutesInZone3 = jsonEvent[@"zone3"];
    event.minutesInZone4 = jsonEvent[@"zone4"];
    event.minutesInZone5 = jsonEvent[@"zone5"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *start = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@", event.startString, event.startTimeString]];
    NSDate *end = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ %@", event.startString, event.endTimeString]];
    
    while ([end timeIntervalSinceDate:start] < 0) {
        end = [end dateByAddingTimeInterval:60*60*24*1]; // add 1 day
    }
    
    event.start = start;
    event.end = end;
    
    event.targetZone = TZRangeMake([event.targetZoneMin integerValue], [event.targetZoneMax integerValue]);
    
    return event;
}

@end
