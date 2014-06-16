//
//  EventResponseDelegate.m
//  MyZone
//
//  Created by Matthew Hillman on 4/4/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "EventResponseDelegate.h"
#import "MZQuery.h"
#import "MZEvent.h"

@interface EventResponseDelegate ()
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation EventResponseDelegate

- (id)initWithContext:(NSManagedObjectContext *)context
{
    if (!(self = [super init])) return nil;
    self.context = context;
    return self;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
//    NSDictionary *response = [MZQuery processResult:location];
//    if ([response[@"dates"][@"events"] isKindOfClass:[NSArray class]]) {
//        NSArray *jsonEvents = response[@"dates"][@"events"];
//        for (NSDictionary *jsonEvent in jsonEvents) {
//            MZEvent *event = [MZEvent eventForJSONEventDictionary:jsonEvent];
//            [self getUserWorkoutsForEvent:event];
//        }
//    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

@end
