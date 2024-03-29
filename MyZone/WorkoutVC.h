//
//  ViewController.h
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Workout;

@interface WorkoutVC : UIViewController
@property (strong, nonatomic) Workout *workout;
@property (strong, nonatomic) NSArray *activityList;
@end
