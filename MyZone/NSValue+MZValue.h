//
//  NSValue+MZValue.h
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSValue (MZValue)
+ (NSValue *)valueWithMZPoint:(MZPoint)point;
- (MZPoint)mzPointValue;
@end
