//
//  PageViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "PageViewController.h"

#import "AppDelegate.h"

#import "Constants.h"

@interface PageViewController ()

@end

@implementation PageViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.scrollView = (UIScrollView *)view;
            [self.scrollView setDelegate:self];
        }
    }
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.scrollView addGestureRecognizer:recognizer];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    self.mainTableViewController = [[MainTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.setUpTableViewController = [[SetUpTableViewController alloc] init];
    self.setupNavigationController = [[CustomNavigationController alloc] initWithRootViewController:self.mainTableViewController];
    [self.setupNavigationController setNavigationBarHidden:YES animated:NO];
    
    self.cameraViewController = [[CameraViewController alloc] init];
    [self.cameraViewController.view addSubview:self.setupNavigationController.view];
    [self.cameraViewController addChildViewController:self.setupNavigationController];
    [self.setupNavigationController didMoveToParentViewController:self.cameraViewController];
    self.mainTableViewController.delegate = self.cameraViewController;
    self.setUpTableViewController.delegate = self.cameraViewController;
    
    self.streamTableViewController = [[StreamTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.streamNavigationController = [[CustomNavigationController alloc] initWithRootViewController:self.streamTableViewController];
    [self.streamNavigationController setNavigationBarHidden:YES animated:NO];
    
    self.libraryCollectionViewController = [[LibraryCollectionViewController alloc] init];
    [self.libraryCollectionViewController loadRecentPictures];
    
    [[self.streamTableViewController loadCache] continueWithBlock:^id(BFTask *task) {
        [self.mainTableViewController loadCache];
        return nil;
    }];
    [self.setUpTableViewController loadCache];
    
    [self setViewControllers:@[self.cameraViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.currentViewController = self.cameraViewController;
    
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"log_awgy: swipe");
}

//- (void) viewDidLoad {
//    scrollView.bounces = NO
//    scrollView.pagingEnabled = YES
//}

- (void)viewDidLayoutSubviews {
    [self initScrollView];
}

- (void)initScrollView {

    //viewController1.willMoveToParentViewController(self)
    //viewController1.view.frame = scrollView.bounds
    
    //viewController2.willMoveToParentViewController(self)
    //viewController2.view.frame.size = scrollView.frame.size
    //viewController2.view.frame.origin = CGPoint(x: view.frame.width, y: 0)
    
    //scrollView.contentSize = CGSize(width: 2 * scrollView.frame.width, height: scrollView.frame.height)
    
    //scrollView.addSubview(viewController2.view)
    //self.addChildViewController(viewController2)
    //viewController2.didMoveToParentViewController(self)
    
    //scrollView.addSubview(viewController1.view)
    //self.addChildViewController(viewController1)
    //viewController1.didMoveToParentViewController(self)
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
        
        if (size.width > size.height) {
            self.dataSource = nil;
        } else {
            self.dataSource = self;
        }
        
    }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {

                                 }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[CameraViewController class]]) {
        return nil;
    } else {
        return self.cameraViewController;
    }

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[CameraViewController class]]) {
        return self.streamNavigationController;
    } else {
        return nil;
    }
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(nonnull NSArray<UIViewController *> *)pendingViewControllers {

}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(nonnull NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint lastOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0.0f);
    CGPoint nowOffset = scrollView.contentOffset;
    if ([self.currentViewController isKindOfClass:[CameraViewController class]]) {
        float check = [self.streamTableViewController.objects count] ? -[UIScreen mainScreen].bounds.size.width : 0;
        if ((lastOffset.x - nowOffset.x) > 0 || (lastOffset.x - nowOffset.x) < check ) {
            @try {
                [scrollView setContentOffset:lastOffset animated:NO];
            } @catch (NSException *exception) {
                NSLog(@"Exception a");
            }
        }
    } else if ([self.currentViewController isKindOfClass:[StreamTableViewController class]]) {
        if ((lastOffset.x - nowOffset.x) < 0 || (lastOffset.x - nowOffset.x) > [UIScreen mainScreen].bounds.size.width) {
            @try {
                [scrollView setContentOffset:lastOffset animated:NO];
            } @catch (NSException *exception) {
                NSLog(@"Exception b");
            }
        }
    }
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate {

    if ([self.viewControllers count] && [self.viewControllers[0] isKindOfClass:[CustomNavigationController class]]) {
        return [[self.streamNavigationController.viewControllers lastObject] shouldAutorotate];
    } else if ([self.viewControllers count] && [self.viewControllers[0] isKindOfClass:[CameraViewController class]]) {
        return [[self.setupNavigationController.viewControllers lastObject] shouldAutorotate];
    } else {
        return [super shouldAutorotate];
    }
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if ([self.viewControllers count] && [self.viewControllers[0] isKindOfClass:[CustomNavigationController class]]) {
        return [[self.streamNavigationController.viewControllers lastObject] supportedInterfaceOrientations];
    } else if ([self.viewControllers count] && [self.viewControllers[0] isKindOfClass:[CameraViewController class]]) {
        return [[self.setupNavigationController.viewControllers lastObject] supportedInterfaceOrientations];
    } else {
        return [super supportedInterfaceOrientations];
    }
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {

    if ([self.viewControllers count] && [self.viewControllers[0] isKindOfClass:[CustomNavigationController class]]) {
        return [[self.streamNavigationController.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
    } else if ([self.viewControllers count] && [self.viewControllers[0] isKindOfClass:[CameraViewController class]]) {
        return [[self.setupNavigationController.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
    } else {
        return [super preferredInterfaceOrientationForPresentation];
    }
    
}

@end
