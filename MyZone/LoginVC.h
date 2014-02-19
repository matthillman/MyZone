//
//  LoginVC.h
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MZLoginDelegate <NSObject>

-(void)loginSuccess;

@end

@interface LoginVC : UIViewController
@property (weak, nonatomic) id<MZLoginDelegate>delegate;
+ (BOOL)isLoggedIn;
+ (UIViewController *)loginViewControllerWithDelegate:(id<MZLoginDelegate>)delegate;
@end
