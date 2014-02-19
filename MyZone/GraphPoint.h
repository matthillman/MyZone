//
//  GraphPoint.h
//  MyZone
//
//  Created by Matthew Hillman on 2/11/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphPoint : NSObject
@property (assign, nonatomic) CGPoint point;
@property (strong, nonatomic) NSString *category;
@property (readonly, nonatomic) CGFloat x;
@property (readonly, nonatomic) CGFloat y;
- (id)initWithPoint:(CGPoint)point category:(NSString *)category;
+ (GraphPoint *)pointFromCGPoint:(CGPoint)point category:(NSString *)category;
@end
