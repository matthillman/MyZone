//
//  Effort.h
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Workout;

@interface Effort : NSManagedObject

@property (nonatomic, retain) NSNumber * z;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * effort;
@property (nonatomic, retain) Workout *workout;

@end
