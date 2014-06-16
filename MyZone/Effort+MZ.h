//
//  Effort+MZ.h
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "Effort.h"

@interface Effort (MZ)

+ (Effort *)effortFrom:(MZPoint)point inContext:(NSManagedObjectContext *)context;

@end
