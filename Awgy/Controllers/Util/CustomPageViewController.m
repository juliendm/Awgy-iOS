//
//  CustomPageViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "CustomPageViewController.h"

@interface CustomPageViewController ()

@end

@implementation CustomPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.dataSource = self;
    self.delegate = self;
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setDelegate:self];
        }
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
        CGPoint distance = [scrollView.panGestureRecognizer translationInView:scrollView];
        if (fabs(velocity.y) > 0 && fabs(distance.y) > 15) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

@end
