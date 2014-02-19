//
//  ScrollingImageView.m
//  MyZone
//
//  Created by Matthew Hillman on 2/14/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "ScrollingImageVC.h"
#import "CenteringScrollView.h"

@interface ScrollingImageVC () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet CenteringScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) BOOL hideStatusBar;
@end

@implementation ScrollingImageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.tileContainerView = self.imageView;
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 10;
    self.scrollView.delegate = self;
    [self updateZoom];
}

- (void)updateZoom
{
    CGFloat minWidth = CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.minimumZoomScale = minWidth / self.image.size.width;
    self.scrollView.maximumZoomScale = MAX(10, self.scrollView.minimumZoomScale);
    
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setScrollView:(CenteringScrollView *)scrollView
{
    _scrollView = scrollView;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self updateZoom];
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self updateZoom];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.tabBarController.tabBar.hidden = YES;
        self.hideStatusBar = YES;
    } else {
        self.tabBarController.tabBar.hidden = NO;
        self.hideStatusBar = NO;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [self.view layoutIfNeeded];
    [self.navigationController setNavigationBarHidden:self.hideStatusBar animated:YES];
    [self prefersStatusBarHidden];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    [UIView commitAnimations];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self prefersStatusBarHidden];
    [self updateZoom];
}

- (BOOL)prefersStatusBarHidden
{
    return self.hideStatusBar;
}


@end
