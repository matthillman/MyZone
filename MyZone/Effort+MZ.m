//
//  Effort+MZ.m
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "Effort+MZ.h"

@implementation Effort (MZ)

+ (Effort *)effortFrom:(MZPoint)point inContext:(NSManagedObjectContext *)context
{
    Effort *effort = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Effort" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time = %@", @(point.time)];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        LogError(@"%@", error.debugDescription);
    } else if ([fetchedObjects count]) {
        effort = [fetchedObjects lastObject];
    } else {
        effort = [NSEntityDescription insertNewObjectForEntityForName:@"Effort" inManagedObjectContext:context];
        effort.time = @(point.time);
    }
    
    effort.effort = @(point.effort);
    effort.z = @(point.zone);
    
    return effort;
}

@end
