//
//  MZDefs.h
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#ifndef MyZone_MZDefs_h
#define MyZone_MZDefs_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef struct _TZRange {
    NSUInteger min;
    NSUInteger max;
} TZRange;

NS_INLINE TZRange TZRangeMake(NSUInteger min, NSUInteger max) {
    TZRange r;
    r.min = min;
    r.max = max;
    return r;
}

NS_INLINE BOOL TZRangesEqual(TZRange range1, TZRange range2) {
    return (range1.min == range2.min && range1.max == range2.max);
}
typedef enum : NSUInteger {
    MZZone0 = 0,
    MZZone1 = 1,
    MZZone2 = 2,
    MZZone3 = 3,
    MZZone4 = 4,
    MZZone5 = 5,
} MZZoneKey;

typedef struct _MZPoint {
    NSTimeInterval time;
    NSUInteger effort;
    MZZoneKey zone;
} MZPoint;

NS_INLINE MZPoint MZPointMake(NSTimeInterval time, NSUInteger effort, MZZoneKey zone) {
    MZPoint p;
    p.time = time;
    p.effort = effort;
    p.zone = zone;
    return p;
}

NS_INLINE CGPoint CGPointFromMZPoint(MZPoint point) {
    return CGPointMake(point.time, point.effort);
}

#endif
