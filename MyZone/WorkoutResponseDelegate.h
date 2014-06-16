//
//  WorkoutResponseDelegate.h
//  MyZone
//
//  Created by Matthew Hillman on 4/4/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MZEvent;

@interface WorkoutResponseDelegate : NSObject <NSURLSessionDownloadDelegate>
- (id)initWithEvent:(MZEvent *)event context:(NSManagedObjectContext *)context;
@end
