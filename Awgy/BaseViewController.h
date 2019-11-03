//
//  BaseViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>

#import "StreamTableViewController.h"
#import "SetUpTableViewController.h"

#import "PageViewController.h"

#import "ClassTableViewController.h"

#import "CameraViewController.h"

@interface BaseViewController : UIViewController <StreamTableViewControllerDelegate, ClassTableViewControllerDelegate>

@property (nonatomic, strong) PageViewController *pageViewController;

- (void)firstArrival:(BOOL)animated;

- (BFTask *)applicationDidReceiveRemoteNotification:(NSDictionary *)notificationPayload inBackground:(BOOL)inBackground;
- (void)userDidPressRemoteNotification:(NSDictionary *)notificationPayload;

@end
