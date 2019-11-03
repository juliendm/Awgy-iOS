//
//  AppDelegate.h
//  Awgy
//
//  Copyright 2015 Parse, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationController.h"

#import "GroupSelfie.h"
#import "BaseViewController.h"

#import <UserNotifications/UserNotifications.h>

@protocol AppDelegateDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) BaseViewController *baseViewController;

@property (nonatomic) BOOL keyboardIsShowing;

@property (nonatomic) BOOL cameraIsPressing;
@property (nonatomic) BOOL capture;

@property (nonatomic, strong) NSString *showingGroupSelfieId;
@property (nonatomic, strong) NSString *zoomedGroupSelfieId;

@property (nonatomic, strong) CustomNavigationController *rootNavigationController;
@property (nonatomic, strong) CustomNavigationController *mainNavigationController;

@property (nonatomic, weak) id<AppDelegateDelegate> delegate;

- (void)resetPageViewControllerDataSource;
- (void)removePageViewControllerDataSource;

@end


@protocol AppDelegateDelegate <NSObject>
@optional

- (void)appDelegate:(AppDelegate *)appDelegate didSnapGroupSelfie:(GroupSelfie *)groupSelfie;

@end

