//
//  EventResponseDelegate.h
//  MyZone
//
//  Created by Matthew Hillman on 4/4/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventResponseDelegate : NSObject <NSURLSessionDownloadDelegate>
- (id)initWithContext:(NSManagedObjectContext *)context;
@end
