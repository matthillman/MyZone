//
//  AppDelegate.m
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+MDC.h"
#import "LoginVC.h"
#import "WorkoutListVC.h"
#import "MZQuery.h"

@interface AppDelegate ()
@property (strong, nonatomic) UIManagedDocument *document;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    self.document = [self openDocumentNamed:[NSString stringWithFormat:@"MZ-%@", [MZQuery loggedInId]] completion:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification
                                                                object:self
                                                              userInfo:@{ DatabaseAvailabilityContext: self.document.managedObjectContext }];
        } else {
            LogError(@"Could not open database");
        }
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (![LoginVC isLoggedIn]) {
        WorkoutListVC *vc = (WorkoutListVC *)[[(UINavigationController *)self.window.rootViewController viewControllers] firstObject];
        [vc presentViewController:[LoginVC loginViewControllerWithDelegate:vc] animated:NO completion:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.context) {
        [MZQuery doWorkoutQueryInContext:self.context all:NO completion:^(BOOL newData) {
            completionHandler(newData ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
            LogDebug(@"New Data: %@", newData ? @"YES" : @"NO");
        }];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (NSManagedObjectContext *)context
{
    return self.document.managedObjectContext;
}

@end
