//
//  ImagesPageViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "GroupSelfie.h"
#import "SingleSelfiesTableViewController.h"

@interface ImagesPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) GroupSelfie *groupSelfie;
@property (nonatomic, strong) SingleSelfiesTableViewController *singleSelfiesTableViewController;

@end