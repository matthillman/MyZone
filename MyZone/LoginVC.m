//
//  LoginVC.m
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "LoginVC.h"
#import "MZQuery.h"
@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@end

@implementation LoginVC

+ (UIViewController *)loginViewControllerWithDelegate:(id<MZLoginDelegate>)delegate
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginVC *loginVC = [sb instantiateViewControllerWithIdentifier:@"Login View"];
    loginVC.delegate = delegate;
    return loginVC;
}

- (IBAction)doLogin
{
    if ([MZQuery loginUser:self.emailText.text password:self.passwordText.text]) {
        [self.delegate loginSuccess];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Login Failure"
                                    message:@"THere as an error logging in."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

+ (BOOL)isLoggedIn
{
    return [MZQuery isLoggedIn];
}

@end
