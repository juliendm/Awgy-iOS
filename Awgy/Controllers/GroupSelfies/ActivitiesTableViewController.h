//
//  ActivitiesTableViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ClassTableViewController.h"

#import "GroupSelfie.h"

@protocol ActivitiesTableViewControllerDelegate;

@interface ActivitiesTableViewController : ClassTableViewController

@property (nonatomic, strong) GroupSelfie *groupSelfie;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic) BOOL showingImage;

@property (nonatomic, weak) id<ClassTableViewControllerDelegate, ActivitiesTableViewControllerDelegate> delegate;

- (void)scrollDown;

@end

@protocol ActivitiesTableViewControllerDelegate <NSObject>
@optional

- (void)activitiesTableViewController:(ActivitiesTableViewController *)activitiesTableViewController didSwipeRightView:(UIView *)view;

@end
