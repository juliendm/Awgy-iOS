//
//  PageViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "StreamTableViewController.h"
#import "CameraViewController.h"

#import "MainTableViewController.h"
#import "SetUpTableViewController.h"

#import "CustomNavigationController.h"

#import "LibraryCollectionViewController.h"

@interface PageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) CameraViewController *cameraViewController;

@property (nonatomic, strong) MainTableViewController *mainTableViewController;
@property (nonatomic, strong) SetUpTableViewController *setUpTableViewController;
@property (nonatomic, strong) CustomNavigationController *setupNavigationController;

@property (nonatomic, strong) StreamTableViewController *streamTableViewController;
@property (nonatomic, strong) CustomNavigationController *streamNavigationController;

@property (nonatomic, strong) LibraryCollectionViewController *libraryCollectionViewController;

@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, strong) UIScrollView *scrollView;

@end
