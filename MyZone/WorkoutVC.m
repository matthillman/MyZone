//
//  ViewController.m
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "WorkoutVC.h"
#import "MEPsLabel.h"
#import "ArrayDataSource.h"
#import "MZWorkout.h"
#import "ScrollingImageVC.h"
#import "WorkoutHeading.h"
#import "WorkoutCell.h"
#import "ScrollingChartView.h"
#import "BarChart.h"
#import "MZQuery.h"

static NSString *const HeaderViewIdentifier = @"Workout Head";
static NSString *const CellIdentifier = @"Workout Cell";

@interface WorkoutVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet ScrollingChartView *chartView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet ArrayDataSource *dataSource;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartHeight;

@property (strong, nonatomic) UIButton *titleButton;
@end

@implementation WorkoutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.titleButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
    [self.titleButton setTitle:self.workout.activity forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleButton addTarget:self action:@selector(showActions) forControlEvents:UIControlEventTouchUpInside];
    [self.titleButton sizeToFit];
    self.navigationItem.titleView = self.titleButton;
    
    
    self.chartView.colors = self.workout.grapher.colors;
    self.chartView.points = self.workout.grapher.points;
    
    self.chartView.target = self;
    self.chartView.action = @selector(showChart);
    
    [self.dataSource configureForItems:self.workout.detailViews cellIdentifier:CellIdentifier configureCellBlock:^(WorkoutCell *cell, NSDictionary *item) {
        cell.headLabel.text = item[@"title"];
        UIView *v = item[@"view"];
        CGRect newFrame = cell.containerView.frame;
        newFrame.origin = CGPointZero;
        v.frame = newFrame;
        [cell.containerView addSubview:v];
        [cell.containerView layoutSubviews];
    }];
    
}

- (void)showActions
{
    UIActionSheet *activitySheet = [[UIActionSheet alloc] initWithTitle:@"Change Activity for Workout" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSDictionary *act in self.workout.activityList) {
        [activitySheet addButtonWithTitle:act[@"label"]];
    }
    [activitySheet addButtonWithTitle:@"Cancel"];
    activitySheet.cancelButtonIndex = activitySheet.numberOfButtons-1;
    activitySheet.tintColor = [UIColor colorForR:255 G:22 B:23 A:1];
    [activitySheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner startAnimating];
        self.navigationItem.titleView = spinner;
        [MZQuery updateWorkout:self.workout.hrhIndex activity:self.workout.activityList[buttonIndex][@"value"] completionHandler:^(id response) {
            NSString *selectedActivity = (NSString *)response;
            [self.titleButton setTitle:selectedActivity forState:UIControlStateNormal];
            [self.titleButton sizeToFit];
            self.navigationItem.titleView = self.titleButton;
            self.workout.activity = selectedActivity;
        }];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            [button setTitleColor:[UIColor colorForR:255 G:22 B:23 A:1] forState:UIControlStateNormal|UIControlStateSelected|UIControlStateHighlighted];
        }
    }
}

- (void)showChart
{
    [self performSegueWithIdentifier:@"show chart" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show chart"]) {
        ScrollingImageVC *vc = (ScrollingImageVC *)segue.destinationViewController;
        vc.image = [self.workout workoutGraphFullWidthAtSize:CGSizeMake(568, 320)];
        vc.navigationItem.title = @"Workout Graph";
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    WorkoutHeading *rv = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderViewIdentifier forIndexPath:indexPath];
    
    [rv configureWithWorkout:self.workout];
    
    return rv;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource collectionView:collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.chartHeight.constant = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 160 : 120;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

@end
