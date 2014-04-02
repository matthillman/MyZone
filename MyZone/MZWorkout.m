//
//  MZWorkout.m
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "MZWorkout.h"
#import "GraphPoint.h"
#import "BarChart.h"
#import "MEPsLabel.h"
#import "EffortLabel.h"

@interface MZWorkout () <NSCopying>

@property (strong, nonatomic) NSNumber *data0;
@property (strong, nonatomic) NSNumber *data1;
@property (strong, nonatomic) NSNumber *data2;
@property (strong, nonatomic) NSNumber *data3;
@property (strong, nonatomic) NSNumber *data4;
@property (strong, nonatomic) NSNumber *data5;
@property (strong, nonatomic) NSNumber *targetZoneMax;
@property (strong, nonatomic) NSNumber *targetZoneMin;

@property (strong, nonatomic) NSString *startString;
@property (strong, nonatomic) NSString *endString;

@property (strong, nonatomic) BarChart *grapher;

@end

@implementation MZWorkout

+ (NSArray *)workoutsForJSONWorkoutDictionary:(NSDictionary *)jsonWorkout
{
    NSMutableArray *ret = [@[] mutableCopy];
    // if there are multiple workouts in one day, MyZone returns the data such that most of it is
    // the same. The only thing really different are the activity name, start/end times and the
    // heart rate graph. Thus, we build one workout and then use it as a base to build what
    // is returned.
    MZWorkout *workout = [[MZWorkout alloc] init];
    
    workout.averageEffort = jsonWorkout[@"averageEffort"];
    workout.averageHeartRate = jsonWorkout[@"averageHeartRate"];
    workout.calories = jsonWorkout[@"calories"];
    workout.data0 = jsonWorkout[@"data0"];
    workout.minutesInZone0 = jsonWorkout[@"data0a"];
    workout.data1 = jsonWorkout[@"data1"];
    workout.minutesInZone1 = jsonWorkout[@"data1a"];
    workout.data2 = jsonWorkout[@"data2"];
    workout.minutesInZone2 = jsonWorkout[@"data2a"];
    workout.data3 = jsonWorkout[@"data3"];
    workout.minutesInZone3 = jsonWorkout[@"data3a"];
    workout.data4 = jsonWorkout[@"data4"];
    workout.minutesInZone4 = jsonWorkout[@"data4a"];
    workout.data5 = jsonWorkout[@"data5"];
    workout.minutesInZone5 = jsonWorkout[@"data5a"];
    workout.effortInZone0 = @[];
    workout.effortInZone1 = @[];
    workout.effortInZone2 = @[];
    workout.effortInZone3 = @[];
    workout.effortInZone4 = @[];
    workout.effortInZone5 = @[];
    NSRange zones = NSMakeRange(0, 6);
    NSUInteger zone;
    NSMutableDictionary *acts = [@{} mutableCopy];
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
                acts[actKey] = @{@"name": item[2], @"start": item[3], @"end": item[4]};
            }
        }
    }
    
    workout.endString = jsonWorkout[@"mobend"];
    workout.startString = jsonWorkout[@"mobstart"];
    workout.numberOfMoves = jsonWorkout[@"numberOfMoves"];
    workout.meps = jsonWorkout[@"points"];
    workout.mepsInZone1 = jsonWorkout[@"points1"];
    workout.mepsInZone2 = jsonWorkout[@"points2"];
    workout.mepsInZone3 = jsonWorkout[@"points3"];
    workout.mepsInZone4 = jsonWorkout[@"points4"];
    workout.mepsInZone5 = jsonWorkout[@"points5"];
    workout.targetZoneMax = jsonWorkout[@"targetZoneMax"];
    workout.targetZoneMin = jsonWorkout[@"targetZoneMin"];
    workout.targetZoneDuration = jsonWorkout[@"targetZoneMinutes"];
    workout.totalDuration = jsonWorkout[@"totalDuration"];
    workout.targetZone = TZRangeMake([workout.targetZoneMin integerValue], [workout.targetZoneMax integerValue]);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    for (NSString *activity in acts) {
        workout.start = [dateFormat dateFromString:workout.startString];
        workout.end = [dateFormat dateFromString:workout.endString];
        NSInteger peakHr = 0;
        if (!workout.start || !workout.end) {
            NSDate *start = [dateFormat dateFromString:acts[activity][@"start"]];
            NSDate *end = [dateFormat dateFromString:acts[activity][@"end"]];
            
            if (!workout.start || [start timeIntervalSince1970] < [workout.start timeIntervalSince1970]) {
                workout.start = start;
            }
            if (!workout.end || [end timeIntervalSince1970] < [workout.end timeIntervalSince1970]) {
                workout.end = end;
            }
        }
        
        for (zone = zones.location; zone < zones.length; ++zone) {
            NSArray *data = effortsByActivity[activity][@(zone)] ?: @[];
            for (NSValue *v in data) {
                MZPoint p = [v mzPointValue];
                peakHr = MAX(peakHr, p.effort);
            }
            SEL set = NSSelectorFromString([NSString stringWithFormat:@"setEffortInZone%lu:", (unsigned long)zone]);
            IMP setImp = [workout methodForSelector:set];
            void (*setFunc)(id, SEL, NSArray *) = (void *)setImp;
            setFunc(workout, set, data);
        }
        
        workout.peakHeartRate = @(peakHr);
        
        [ret addObject:[workout copy]];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
    NSArray *sorted = [ret sortedArrayUsingDescriptors:@[descriptor]];
    
    NSError *error = NULL, *optError = NULL;
    NSRegularExpression *selectRegex = nil, *optionRegex = nil;
    NSTextCheckingResult *match = nil;
    
    optionRegex = [NSRegularExpression regularExpressionWithPattern:@"<option.+?value='(.+?)'.*?>(.+?)</option>" options:0 error:&optError];
    
    for (MZWorkout *w in sorted) {
        NSUInteger i = [sorted indexOfObject:w];
        w.move = @(i+1);
        w.hrhIndex = jsonWorkout[@"actlist"][i][@"value"];
        w.activity = jsonWorkout[@"actlist"][i][@"name"];
        selectRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"<select.+?selActivity%@.+?>(.+?)</select>", w.hrhIndex]
                                                                options:0
                                                                  error:&error];
        if (error != NULL) {
            LogError(@"%@", [error debugDescription]);
        }
        match = [selectRegex firstMatchInString:jsonWorkout[@"activities"]
                                        options:0
                                          range:NSMakeRange(0, [jsonWorkout[@"activities"] length])];
        if (match) {
            NSMutableArray *activityList = [NSMutableArray array];
            [optionRegex enumerateMatchesInString:jsonWorkout[@"activities"]
                                          options:0
                                            range:[match rangeAtIndex:1]
                                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
             {
                 NSString *val = [jsonWorkout[@"activities"] substringWithRange:[result rangeAtIndex:1]];
                 NSString *label = [jsonWorkout[@"activities"] substringWithRange:[result rangeAtIndex:2]];
                 [activityList addObject:@{@"value": val, @"label": label}];
            }];
            
            if (optError != NULL) {
                LogError(@"%@", [optError debugDescription]);
            }
            
            w.activityList = [activityList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES]]];
        }
    }
    
    return ret;
}

- (NSArray *)effort
{
    return [[[[[self.effortInZone0 arrayByAddingObjectsFromArray:self.effortInZone1]
                                   arrayByAddingObjectsFromArray:self.effortInZone2]
                                   arrayByAddingObjectsFromArray:self.effortInZone3]
                                   arrayByAddingObjectsFromArray:self.effortInZone4]
                                   arrayByAddingObjectsFromArray:self.effortInZone5];
}

- (NSArray *)graphPoints
{
    NSMutableArray *points = [@[] mutableCopy];
    
    for (NSValue *v in self.effort) {
        MZPoint p = [v mzPointValue];
        [points addObject:[[GraphPoint alloc] initWithPoint:CGPointMake(p.time, p.effort) category:[NSString stringWithFormat:@"%lu", (unsigned long)p.zone]]];
    }
    
    return points;
}

- (BarChart *)grapher
{
    if (!_grapher) {
        _grapher = [[BarChart alloc] init];
        _grapher.yRange = NSMakeRange(0, 100);
        _grapher.colors = @{@"0": @{@"fill": [UIColor fillColorForZone:MZZone0]},
                            @"1": @{@"fill": [UIColor fillColorForZone:MZZone1]},
                            @"2": @{@"fill": [UIColor fillColorForZone:MZZone2]},
                            @"3": @{@"fill": [UIColor fillColorForZone:MZZone3]},
                            @"4": @{@"fill": [UIColor fillColorForZone:MZZone4]},
                            @"5": @{@"fill": [UIColor fillColorForZone:MZZone5]}};
    }
    
    NSArray *p = self.graphPoints;
    if (![_grapher.points isEqualToArray:p]) _grapher.points = p;
    
    return _grapher;
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
    self.grapher.thumbnail = thumbnail;
    self.grapher.average = average;
    return [self.grapher renderImgaeAtSize:size];
}

- (UIImage *)workoutGraphFullWidthAtSize:(CGSize)size
{
    return [self workoutGraphAtSize:size thumbnail:NO average:NO];
}

- (NSArray *)detailViews
{
    NSMutableArray *ret = [@[] mutableCopy];
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

- (id)copyWithZone:(NSZone *)zone
{
    MZWorkout *w = [[[self class] allocWithZone:zone] init];
    
    w->_averageEffort = [_averageEffort copyWithZone:zone];
    w->_averageHeartRate = [_averageHeartRate copyWithZone:zone];
    w->_peakHeartRate = [_peakHeartRate copyWithZone:zone];
    w->_maxHeartRate = [_maxHeartRate copyWithZone:zone];
    w->_calories = [_calories copyWithZone:zone];
    w->_data0 = [_data0 copyWithZone:zone];
    w->_minutesInZone0 = [_minutesInZone0 copyWithZone:zone];
    w->_data1 = [_data1 copyWithZone:zone];
    w->_minutesInZone1 = [_minutesInZone1 copyWithZone:zone];
    w->_data2 = [_data2 copyWithZone:zone];
    w->_minutesInZone2 = [_minutesInZone2 copyWithZone:zone];
    w->_data3 = [_data3 copyWithZone:zone];
    w->_minutesInZone3 = [_minutesInZone3 copyWithZone:zone];
    w->_data4 = [_data4 copyWithZone:zone];
    w->_minutesInZone4 = [_minutesInZone4 copyWithZone:zone];
    w->_data5 = [_data5 copyWithZone:zone];
    w->_minutesInZone5 = [_minutesInZone5 copyWithZone:zone];
    w->_effortInZone0 = [_effortInZone0 copyWithZone:zone];
    w->_effortInZone1 = [_effortInZone1 copyWithZone:zone];
    w->_effortInZone2 = [_effortInZone2 copyWithZone:zone];
    w->_effortInZone3 = [_effortInZone3 copyWithZone:zone];
    w->_effortInZone4 = [_effortInZone4 copyWithZone:zone];
    w->_effortInZone5 = [_effortInZone5 copyWithZone:zone];
    w->_endString = [_endString copyWithZone:zone];
    w->_startString = [_startString copyWithZone:zone];
    w->_move = [_move copyWithZone:zone];
    w->_numberOfMoves = [_numberOfMoves copyWithZone:zone];
    w->_meps = [_meps copyWithZone:zone];
    w->_mepsInZone1 = [_mepsInZone1 copyWithZone:zone];
    w->_mepsInZone2 = [_mepsInZone2 copyWithZone:zone];
    w->_mepsInZone3 = [_mepsInZone3 copyWithZone:zone];
    w->_mepsInZone4 = [_mepsInZone4 copyWithZone:zone];
    w->_mepsInZone5 = [_mepsInZone5 copyWithZone:zone];
    w->_targetZoneMax = [_targetZoneMax copyWithZone:zone];
    w->_targetZoneMin = [_targetZoneMin copyWithZone:zone];
    w->_targetZoneDuration = [_targetZoneDuration copyWithZone:zone];
    w->_totalDuration = [_totalDuration copyWithZone:zone];
    w->_targetZone = TZRangeMake(_targetZone.min, _targetZone.max);
    w->_activity = [_activity copyWithZone:zone];
    w->_start = [_start copyWithZone:zone];
    w->_end = [_end copyWithZone:zone];
    
    return w;
}

@end
