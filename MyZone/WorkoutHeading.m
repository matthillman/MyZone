//
//  WorkoutHeading.m
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "WorkoutHeading.h"

@implementation WorkoutHeading

- (void)configureWithDate:(NSDate *)date moveNumber:(NSNumber *)move of:(NSNumber *)totalMoves targetZone:(TZRange)zone maxHr:(NSNumber *)max duration:(NSString *)duration
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    NSDateFormatter *t = [[NSDateFormatter alloc] init];
    f.dateStyle = NSDateFormatterMediumStyle;
    t.timeStyle = NSDateFormatterShortStyle;
    self.dateTimeLabel.text = [NSString stringWithFormat:@"%@ %@ (%@ of %@)", [f stringFromDate:date], [t stringFromDate:date], move, totalMoves];
    self.durationLabel.text = duration;
    self.tzLabel.text = [NSString stringWithFormat:@"Target Zone: %lu%% to %lu%%", (unsigned long)zone.min, (unsigned long)zone.max];
    self.maxHrLabel.text = [NSString stringWithFormat:@"Max HR: %@ BPM", max];
}

@end
