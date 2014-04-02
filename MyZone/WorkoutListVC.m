//
//  WorkoutListVC.m
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "WorkoutListVC.h"
#import "MZQuery.h"
#import "MZEvent.h"
#import "ArrayDataSource.h"
#import "GraphListTableCell.h"
#import "WorkoutVC.h"
#import "MZWorkout.h"

static NSString *const WorkoutCellIdentifier = @"Workout List Cell";

@interface WorkoutListVC ()
@property (strong, nonatomic) IBOutlet ArrayDataSource *dataSource;
@end

@implementation WorkoutListVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([LoginVC isLoggedIn]) {
        [self setup];
    }
    
    self.navigationItem.title = @"Workouts";    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)refresh:(id)sender
{
    [self setup];
}

- (void)setup
{
    [self.refreshControl beginRefreshing];
//    [MZQuery getUserProfile];
    NSDate *s = [NSDate date];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.month = -2;
    s = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:[NSDate date] options:0];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"end" ascending:NO];
    
    [MZQuery getUserEventsFrom:s to:[NSDate date] completionHandler:^(NSArray *events) {
        [self.dataSource configureForItems:@[] cellIdentifier:WorkoutCellIdentifier configureCellBlock:^(GraphListTableCell *cell, MZWorkout *workout) {
            [cell configureForWorkout:workout];
        }];
        
        for (MZEvent *event in events) {
            [MZQuery getUserWorkoutsForEvent:event completionHandler:^(NSArray *workouts) {
                for (MZWorkout *w in workouts) {
                    w.maxHeartRate = event.maximumHeartRate;
                }
                NSArray *unsorted = [self.dataSource.items arrayByAddingObjectsFromArray:workouts];
                self.dataSource.items = [unsorted sortedArrayUsingDescriptors:@[descriptor, descriptor2]];
                [self.tableView reloadData];
            }];
        }
    }];
    
    [self.refreshControl endRefreshing];
}

- (void)loginSuccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setup];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show workout"]) {
        WorkoutVC *vc = (WorkoutVC *)segue.destinationViewController;
        vc.workout = ((GraphListTableCell *)sender).workout;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    for (GraphListTableCell *cell in self.tableView.visibleCells) {
        [cell updateLayout:toInterfaceOrientation];
    }
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    for (GraphListTableCell *cell in self.tableView.visibleCells) {
        [cell updateLayout:self.interfaceOrientation];
    }
}
@end
