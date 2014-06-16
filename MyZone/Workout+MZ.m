//
//  Workout+MZ.m
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "Workout+MZ.h"
#import "Effort+MZ.h"
#import "Activity+MZ.h"
#import "GraphPoint.h"
#import "BarChart.h"
#import "MEPsLabel.h"
#import "EffortLabel.h"

@implementation Workout (MZ)

- (TZRange)targetZone
{
    return TZRangeMake([self.targetZoneMin integerValue], [self.targetZoneMax integerValue]);
}

+ (NSArray *)workoutsForJSONWorkoutDictionary:(NSDictionary *)jsonWorkout inContext:(NSManagedObjectContext *)context
{
    NSMutableDictionary *activitiesByName = [NSMutableDictionary dictionary];
    NSError *error = NULL, *optError = NULL;
    NSRegularExpression *selectRegex = nil, *optionRegex = nil;
    NSTextCheckingResult *match = nil;
    
    optionRegex = [NSRegularExpression regularExpressionWithPattern:@"<option.+?value='(.+?)'.*?>(.+?)</option>" options:0 error:&optError];
    
    selectRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"<select.+?>(.+?)</select>"]
                                                            options:0
                                                              error:&error];
    if (error != NULL) {
        LogError(@"%@", [error debugDescription]);
    }
    match = [selectRegex firstMatchInString:jsonWorkout[@"activities"]
                                    options:0
                                      range:NSMakeRange(0, [jsonWorkout[@"activities"] length])];
    if (match) {
        [optionRegex enumerateMatchesInString:jsonWorkout[@"activities"]
                                      options:0
                                        range:[match rangeAtIndex:1]
                                   usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
         {
             NSString *val = [jsonWorkout[@"activities"] substringWithRange:[result rangeAtIndex:1]];
             NSString *label = [jsonWorkout[@"activities"] substringWithRange:[result rangeAtIndex:2]];
             activitiesByName[label] = [Activity activityWithValue:val label:label inContext:context];
         }];
        
        if (optError != NULL) {
            LogError(@"%@", [optError debugDescription]);
        }
    }
    
    NSMutableArray *workouts = [NSMutableArray array];
    
    NSFetchRequest *fetchRequest = nil;
    
    NSRange zones = NSMakeRange(0, 6);
    NSUInteger zone;
    NSMutableSet *activities = [NSMutableSet set];
    NSMutableDictionary *effortsByActivity = [@{} mutableCopy];
    for (zone = zones.location; zone < zones.length; ++zone) {
        NSArray *data = jsonWorkout[[NSString stringWithFormat:@"effort%lu", (unsigned long)zone]];
        if ([data[0] isKindOfClass:[NSArray class]]) { // if this isn’t a list of arrays, then there is no data in this zone
            for (NSArray *item in data) {
                NSString *actKey = [NSString stringWithFormat:@"%@-%@-%@", item[2], item[3], item[4]];
                MZPoint p = MZPointMake(floor([item[0] doubleValue] / 1000), [item[1] integerValue], zone);
                if (!effortsByActivity[actKey]) effortsByActivity[actKey] = [@{} mutableCopy];
                NSArray *zoneData = effortsByActivity[actKey][@(zone)] ?: @[];
                zoneData = [zoneData arrayByAddingObject:[NSValue valueWithMZPoint:p]];
                effortsByActivity[actKey][@(zone)] = zoneData;
                [activities addObject:@{@"name": item[2], @"start": item[3], @"end": item[4], @"key": actKey}];
            }
        }
    }
    
    NSArray *sortedActivities = [activities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]]];
    
    for (NSDictionary *act in sortedActivities) {
        Workout *workout = nil;
        NSUInteger i = [sortedActivities indexOfObject:act];
        NSNumber *hrhIndex = jsonWorkout[@"actlist"][i][@"value"];
        
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Workout"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"hrhIndex = %@", hrhIndex];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            LogError(@"%@", error.debugDescription);
        } else if ([fetchedObjects count]) {
            workout = [fetchedObjects lastObject];
        } else {
            workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:context];
            workout.hrhIndex = hrhIndex;
        }
        
        fetchRequest = nil;
        
        workout.averageEffort = jsonWorkout[@"averageEffort"];
        workout.averageHeartRate = jsonWorkout[@"averageHeartRate"];
        workout.calories = jsonWorkout[@"calories"];
//        workout.data0 = jsonWorkout[@"data0"];
        workout.minutesInZone0 = jsonWorkout[@"data0a"];
//        workout.data1 = jsonWorkout[@"data1"];
        workout.minutesInZone1 = jsonWorkout[@"data1a"];
//        workout.data2 = jsonWorkout[@"data2"];
        workout.minutesInZone2 = jsonWorkout[@"data2a"];
//        workout.data3 = jsonWorkout[@"data3"];
        workout.minutesInZone3 = jsonWorkout[@"data3a"];
//        workout.data4 = jsonWorkout[@"data4"];
        workout.minutesInZone4 = jsonWorkout[@"data4a"];
//        workout.data5 = jsonWorkout[@"data5"];
        workout.minutesInZone5 = jsonWorkout[@"data5a"];
        
//        workout.endString = jsonWorkout[@"mobend"];
//        workout.startString = jsonWorkout[@"mobstart"];
        workout.numberOfMoves = jsonWorkout[@"numberOfMoves"];
        workout.meps = jsonWorkout[@"points"];
        workout.mepsInZone1 = jsonWorkout[@"points1"];
        workout.mepsInZone2 = jsonWorkout[@"points2"];
        workout.mepsInZone3 = jsonWorkout[@"points3"];
        workout.mepsInZone4 = jsonWorkout[@"points4"];
        workout.mepsInZone5 = jsonWorkout[@"points5"];
        workout.targetZoneMax = jsonWorkout[@"targetZoneMax"];
        workout.targetZoneMin = jsonWorkout[@"targetZoneMin"];
//        TZRange targetZone = TZRangeMake([jsonWorkout[@"targetZoneMin"] integerValue], [jsonWorkout[@"targetZoneMax"] integerValue]);
//        workout.targetZoneData = [NSValue valueWithTZRange:targetZone];
        workout.targetZoneDuration = jsonWorkout[@"targetZoneMinutes"];
        workout.totalDuration = jsonWorkout[@"totalDuration"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        workout.start = [dateFormat dateFromString:jsonWorkout[@"mobstart"]];
        workout.end = [dateFormat dateFromString:jsonWorkout[@"mobend"]];
        NSInteger peakHr = 0;
        if (!workout.start || !workout.end) {
            NSDate *start = [dateFormat dateFromString:act[@"start"]];
            NSDate *end = [dateFormat dateFromString:act[@"end"]];
            
            if (!workout.start || [start timeIntervalSince1970] < [workout.start timeIntervalSince1970]) {
                workout.start = start;
            }
            if (!workout.end || [end timeIntervalSince1970] < [workout.end timeIntervalSince1970]) {
                workout.end = end;
            }
        }
        
        for (zone = zones.location; zone < zones.length; ++zone) {
            NSArray *data = effortsByActivity[act[@"key"]][@(zone)] ?: @[];
            for (NSValue *v in data) {
                MZPoint p = [v mzPointValue];
                peakHr = MAX(peakHr, p.effort);
                [workout.managedObjectContext performBlock:^{
                    [workout addEffortObject:[Effort effortFrom:p inContext:context]];
                }];
            }
        }
        
        workout.peakHeartRate = @(peakHr);
        
        workout.move = @(i+1);
        if (activitiesByName[jsonWorkout[@"actlist"][i][@"name"]]) {
            workout.activity = activitiesByName[jsonWorkout[@"actlist"][i][@"name"]];
        } else {
            workout.activityName = jsonWorkout[@"actlist"][i][@"name"];
        }

        [workouts addObject:workout];
    }
    
    return workouts;
}

- (NSString *)sectionTitle
{
    [self willAccessValueForKey:@"sectionTitle"];
    NSString *sectionTitle = [self primitiveValueForKey:@"sectionTitle"];
    [self didAccessValueForKey:@"sectionTitle"];
    if (sectionTitle == nil) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"MMMM yyyy";
        sectionTitle = [[formatter stringFromDate:self.start] capitalizedString];
        [self setPrimitiveValue:sectionTitle forKey:@"sectionTitle"];
    }
    
    return sectionTitle;
}

- (NSString *)activityName
{
    [self willAccessValueForKey:@"activityName"];
    NSString *activityName = [self primitiveValueForKey:@"activityName"];
    [self didAccessValueForKey:@"activityName"];
    if (self.activity) {
        activityName = self.activity.label;
    }
    
    return activityName;
}

//- (void)setActivity:(Activity *)activity
//{
//    [self willChangeValueForKey:@"activity"];
//    [self setPrimitiveValue:activity forKey:@"activity"];
//    [self didChangeValueForKey:@"activity"];
//    self.activityName = activity.label;
//}

- (NSArray *)graphPoints
{
    NSMutableArray *points = [@[] mutableCopy];
    
    for (Effort *e in self.effort) {
        [points addObject:[[GraphPoint alloc] initWithPoint:CGPointMake([e.time doubleValue], [e.effort doubleValue]) category:[NSString stringWithFormat:@"%@", e.z]]];
    }
    
    return points;
}

- (UIImage *)workoutGraphAtSize:(CGSize)size
{
    return [self workoutGraphAtSize:size thumbnail:NO average:YES];
}
- (UIImage *)workoutThumbnailGraphAtSize:(CGSize)size
{
    return [self workoutGraphAtSize:size thumbnail:YES average:YES];
    
}
- (UIImage *)workoutGraphAtSize:(CGSize)size thumbnail:(BOOL)thumbnail average:(BOOL)average
{
    BarChart *grapher = [[BarChart alloc] init];
    grapher.yRange = NSMakeRange(0, 100);
    grapher.colors = [UIColor fillColors];
    
    grapher.points = self.graphPoints;
    grapher.thumbnail = thumbnail;
    grapher.average = average;
    return [grapher renderImgaeAtSize:size];
}

- (UIImage *)workoutGraphFullWidthAtSize:(CGSize)size
{
    return [self workoutGraphAtSize:size thumbnail:NO average:NO];
}

- (NSArray *)detailViews
{
    NSMutableArray *ret = [NSMutableArray array];
    CGRect subLabelFrame = CGRectMake(0, 0, 100, 30);
    UIFont *labelFont = [UIFont fontWithName:@"AvenirNext" size:14];
    
    MEPsLabel *mepsLabel = [[MEPsLabel alloc] initWithFrame:subLabelFrame];
    mepsLabel.MEPs = self.meps;
    mepsLabel.backgroundColor = [UIColor whiteColor];
    [ret addObject:@{@"title": @"MEPs", @"view": [UIView viewWrappingSubview:mepsLabel]}];
    
    EffortLabel *effortLabel = [[EffortLabel alloc] initWithFrame:subLabelFrame];
    effortLabel.averageEffort = self.averageEffort;
    effortLabel.backgroundColor = [UIColor whiteColor];
    [ret addObject:@{@"title": @"Avg Effort", @"view": [UIView viewWrappingSubview:effortLabel]}];
    
    UILabel *calLabel = [[UILabel alloc] initWithFrame:subLabelFrame];
    calLabel.text = [NSString stringWithFormat:@"%@ Calories", self.calories];
    calLabel.textAlignment = NSTextAlignmentCenter;
    calLabel.font = labelFont;
    [ret addObject:@{@"title": @"Calories Burnt", @"view": [UIView viewWrappingSubview:calLabel]}];
    
    UILabel *zoneLabel = [[UILabel alloc] initWithFrame:subLabelFrame];
    zoneLabel.text = [NSString stringWithFormat:@"%@", self.targetZoneDuration];
    zoneLabel.textAlignment = NSTextAlignmentCenter;
    zoneLabel.font = labelFont;
    [ret addObject:@{@"title": @"Time in Zone", @"view": [UIView viewWrappingSubview:zoneLabel]}];
    
    UILabel *avgHr = [[UILabel alloc] initWithFrame:subLabelFrame];
    avgHr.text = [NSString stringWithFormat:@"%@ BPM", self.averageHeartRate];
    avgHr.textAlignment = NSTextAlignmentCenter;
    avgHr.font = labelFont;
    [ret addObject:@{@"title": @"Avg Heart Rate", @"view": [UIView viewWrappingSubview:avgHr]}];
    
    UILabel *peakHr = [[UILabel alloc] initWithFrame:subLabelFrame];
    peakHr.text = [NSString stringWithFormat:@"%@%%", self.peakHeartRate];
    peakHr.textAlignment = NSTextAlignmentCenter;
    peakHr.font = labelFont;
    [ret addObject:@{@"title": @"Peak Heart Rate", @"view": [UIView viewWrappingSubview:peakHr]}];
    
    return ret;
}


@end
