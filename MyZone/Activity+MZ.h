//
//  Activity+MZ.h
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "Activity.h"

@interface Activity (MZ)
+ (Activity *)activityWithValue:(NSString *)value label:(NSString *)label inContext:(NSManagedObjectContext *)context;
+ (NSArray *)activityListInContext:(NSManagedObjectContext *)context;
@end
