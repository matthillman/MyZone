//
//  WorkoutResponseDelegate.m
//  MyZone
//
//  Created by Matthew Hillman on 4/4/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "WorkoutResponseDelegate.h"
#import "MZEvent.h"
#import "MZQuery.h"
#import "Workout+MZ.h"

@interface WorkoutResponseDelegate ()
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) MZEvent *event;
@end

@implementation WorkoutResponseDelegate

- (id)initWithEvent:(MZEvent *)event context:(NSManagedObjectContext *)context
{
    if (!(self = [super init])) return nil;
    self.context = context;
    self.event = event;
    return self;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSDictionary *response = [MZQuery processResult:location];
    NSArray *workouts = [Workout workoutsForJSONWorkoutDictionary:response[@"chart"] inContext:self.context];
    for (Workout *w in workouts) {
        w.maxHeartRate = self.event.maximumHeartRate;
    }
    [self.context save:NULL];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}
@end
