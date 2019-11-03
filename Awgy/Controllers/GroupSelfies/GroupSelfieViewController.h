//
//  GroupSelfieViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GroupSelfieHeaderView.h"
#import "ActivitiesTableViewController.h"
#import "GroupSelfieFooterView.h"
#import "GroupSelfie.h"
#import "PhoneBook.h"

@interface GroupSelfieViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, GroupSelfieHeaderViewDelegate, GroupSelfieFooterViewDelegate, ClassTableViewControllerDelegate, ActivitiesTableViewControllerDelegate>

@property (nonatomic, strong) GroupSelfie *groupSelfie;

@property (nonatomic, strong) GroupSelfieHeaderView *headerView;

@property (nonatomic, strong) ActivitiesTableViewController *activitiesTableViewController;

@end
