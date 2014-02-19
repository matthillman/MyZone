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

static NSString *const HeaderViewIdentifier = @"Workout Head";
static NSString *const CellIdentifier = @"Workout Cell";

@interface WorkoutVC () <UICollectionViewDataSource, UICollectionViewDelegate>
//@property (weak, nonatomic) IBOutlet UIButton *chartButton;
@property (weak, nonatomic) IBOutlet ScrollingChartView *chartView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet ArrayDataSource *dataSource;
@end

@implementation WorkoutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.chartView.points = self.workout.grapher.points;
    self.chartView.colors = self.workout.grapher.colors;
    
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

- (void)showChart
{
    [self performSegueWithIdentifier:@"show chart" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show chart"]) {
        ScrollingImageVC *vc = (ScrollingImageVC *)segue.destinationViewController;
        vc.image = [self.workout workoutGraphFullWidthAtSize:CGSizeMake(CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds))];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    WorkoutHeading *rv = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderViewIdentifier forIndexPath:indexPath];
    
    [rv configureWithDate:self.workout.start
               moveNumber:self.workout.move
                       of:self.workout.numberOfMoves
               targetZone:self.workout.targetZone
                    maxHr:self.workout.maxHeartRate
                 duration:self.workout.totalDuration];
    
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
@end
