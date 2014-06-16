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
#import "FetchedResultsDataSource.h"
#import "GraphListTableCell.h"
#import "WorkoutVC.h"
#import "Workout.h"
#import "Activity+MZ.h"
#import "AppDelegate.h"

static NSString *const WorkoutCellIdentifier = @"Workout List Cell";

@interface WorkoutListVC ()
@property (strong, nonatomic) IBOutlet FetchedResultsDataSource *dataSource;
@property (strong, nonatomic) NSManagedObjectContext *context;
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
    [self.refreshControl beginRefreshing];
//    [[MZQuery sharedQuery] doWorkoutQueryInContext:self.context all:[sender isKindOfClass:[UIRefreshControl class]]];
//    dispatch_async(dispatch_queue_create("Main Query Queue", 0), ^{
        [MZQuery doWorkoutQueryInContext:self.context all:[sender isKindOfClass:[UIRefreshControl class]] completion:^(BOOL newData) {
            [self.refreshControl endRefreshing];
            LogDebug(@"Query Done");
        }];
//    });
}

- (void)setup
{
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] context];
    if (!self.context) {
        [[NSNotificationCenter defaultCenter] addObserverForName:DatabaseAvailabilityNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          self.context = note.userInfo[DatabaseAvailabilityContext];
                                                      }];
    }
}

- (void)setContext:(NSManagedObjectContext *)context
{
    NSManagedObjectContext *old = _context;
    _context = context;
    if (self.context && ![self.context isEqual:old]) {
        [self contextIsReady];
    }
}

- (void)contextIsReady
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Workout" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = nil;
    NSSortDescriptor *start = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
    NSSortDescriptor *end = [[NSSortDescriptor alloc] initWithKey:@"end" ascending:NO];
    [fetchRequest setSortDescriptors:@[start, end]];
    
    self.dataSource.delegate = self;
    self.dataSource.showSectionIndex = NO;
    [self.dataSource configureForFetchRequest:fetchRequest
                                    inContext:self.context
                       withSectionNameKeyPath:@"sectionTitle"
                               cellIdentifier:WorkoutCellIdentifier
                           configureCellBlock:^(GraphListTableCell *cell, Workout *workout)
     {
         [cell configureForWorkout:workout];
     }];
    
    [self refresh:self];
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
        vc.activityList = [Activity activityListInContext:self.context];
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor lightGrayColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
}

@end
