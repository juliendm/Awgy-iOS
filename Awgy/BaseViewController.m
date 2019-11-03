//
//  BaseViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "BaseViewController.h"

#import "SignUpViewController.h"

#import "AppDelegate.h"

#import <Bolts/BFTask.h>
#import <Bolts/BFTaskCompletionSource.h>

#import "SetUpTableViewController.h"

#import "CustomNavigationController.h"

#import "AGPushNoteView.h"

#import "GroupSelfieViewController.h"
#import "CameraViewController.h"
#import "ImageViewController.h"
#import "VerificationViewController.h"

#import "ConditionsViewController.h"

#import "StreamTableViewCell.h"

#import "NavigationViewController.h"

#import "GroupSelfie.h"
#import "SingleSelfie.h"
#import "Relationship.h"
#import "PhoneBook.h"
#import "Activity.h"
#import "NeedNetwork.h"
#import "PinsOnFile.h"
#import "Constants.h"

#import "MBProgressHUD.h"


@interface BaseViewController()

@property (nonatomic, strong) NSMutableArray *pendingPushViews;

@end

@implementation BaseViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationWillEnterForegroundNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        
        _pendingPushViews = [[NSMutableArray alloc] init];
        
        // Notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:AppDelegateApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:AppDelegateApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser]) {
        
        SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
        [self.navigationController pushViewController:signUpViewController animated:NO];
        
    } else {
        
        //NSLog(@"log_awgy %@",[[UIDevice currentDevice] name]);
        
        [self firstArrival:NO];
        
    }
    
}

- (void)firstArrival:(BOOL)animated {
    
    //[PFUser requestPasswordResetForEmailInBackground:@"awgycompany@gmail.com"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[PFUser currentUser].objectId forKey:kUserDefaultsObjectIdKey];
    
    // Cache Policy
    NeedNetwork *needNetwork = [NeedNetwork sharedInstance];
    [needNetwork clear];
    
    // PhoneBook
    PhoneBook *phoneBook = [PhoneBook sharedInstance];
    if (![phoneBook.name count]) phoneBook.phoneNumber = [PFUser currentUser].username;
    
    self.pageViewController = [[PageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController = [[CustomNavigationController alloc] initWithRootViewController:self.pageViewController];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController.navigationBar.translucent = NO;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController.navigationBarHidden = YES;
    
    [self.navigationController presentViewController:((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController animated:NO completion:^{
        [self.navigationController popToRootViewControllerAnimated:animated];
    }];
    
    //[self checkAnnouncement];
    [self checkUser];
    //[self updateLocation];
    
}



- (void)applicationWillResignActiveNotification:(NSNotification *)note {
    
    // If Misses notification (Internet went down)
    NeedNetwork *needNetwork = [NeedNetwork sharedInstance];
    [needNetwork clear];

}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)note {
    
    //[self checkAnnouncement];
    [self checkUser];
    //[self updateLocation];
    
    [self.pageViewController.libraryCollectionViewController loadRecentPictures];
}

//- (void)updateLocation {
//    
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        if (!error) {
//            PFUser *user = [PFUser currentUser];
//            [user setObject:geoPoint forKey:kUserLocationKey];
//            [user saveInBackground];
//        }
//    }];
//
//}

- (void)checkUser {
    
    if (![PFUser currentUser]) {
        
        if (!([[self.navigationController.viewControllers lastObject] isKindOfClass:[SignUpViewController class]]||
              [[self.navigationController.viewControllers lastObject] isKindOfClass:[VerificationViewController class]])) {
            [self logOutUser];
        }
        
    } else {
            
        NeedNetwork *needNetwork = [NeedNetwork sharedInstance];
        if ([needNetwork needNetworkForKey:kAcceptConditionsKey]) {
            [[PFCloud callFunctionInBackground:kUserFunctionCheckUserKey withParameters:nil] continueWithBlock:^id(BFTask *task) {
                //NSLog(@"log_awgy: %@, %d, %@",[PFUser currentUser].objectId,[task.error code],task.result);
                if (!task.error && task.result) {
                    [needNetwork addDone:kAcceptConditionsKey];
                    int accepted = [task.result intValue];
                    if (!accepted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ConditionsViewController *cvc = [[ConditionsViewController alloc] init];
                            CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:cvc];
                            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController presentViewController:navigationController animated:YES completion:nil];
                        });
                    }
                } else if ([task.error code] == 141) { // 141 : Custom Error Code
                    [self logOutUser]; // MEANS USER OR SESSION OR INSTALLATION IS DELETED
                }
                return nil;
            }];
        }
        // ([task.error code] != 100 && [task.error code] != 401 && [task.error code] != 3840) { // 100 : No internet; 401 : unauthorized, 3840 : Server is down
    }
    
}

#pragma mark - MenuViewControllerDelegate

- (void)logOutUser {
     
    [[PFInstallation currentInstallation] removeObjectForKey:kInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        PhoneBook *phoneBook = [PhoneBook sharedInstance];
        [phoneBook clear];
        NeedNetwork *needNetwork = [NeedNetwork sharedInstance];
        [needNetwork clear];
        
        PinsOnFile *pinsOnFile = [PinsOnFile sharedInstance];
        [[pinsOnFile clear] continueWithBlock:^id(BFTask *task) {
            
            [PFUser logOut];
            
            [self dismissViewControllerAnimated:YES completion:^{
                ((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController = nil;
            }];
            
            return nil;
        }];
        
    }];
    
}

#pragma mark - Remote Notification center

- (BFTask *)applicationDidReceiveRemoteNotification:(NSDictionary *)notificationPayload inBackground:(BOOL)inBackground {
    
    if (!inBackground) {
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation.badge = 0;
        [installation saveInBackground];
    }
    
    if ([[notificationPayload objectForKey:kPushPayloadPayloadKey] isEqualToString:kPushPayloadPayloadActivityKey]) {
    
        NSLog(@"log_awgy: RECIEVED REMOTE NOTIFICATION");
        
        if ([[notificationPayload objectForKey:kPushPayloadTypeKey] isEqualToString:kPushPayloadTypeCreatedKey] ||
            [[notificationPayload objectForKey:kPushPayloadTypeKey] isEqualToString:kPushPayloadTypeParticipatedKey]) {
            
            return [[[GroupSelfie groupSelfieWithNotificationPayload:notificationPayload] continueWithBlock:^id(BFTask *task) {
                if (!task.error && task.result) {
                    return [[Activity activityWithNotificationPayload:notificationPayload] continueWithBlock:^id(BFTask *activityTask) {
                        if (!activityTask.error && activityTask.result) {
                            return task;
                        } else {
                            return activityTask;
                        }
                    }];
                } else {
                    return task;
                }
            }] continueWithBlock:^id(BFTask *task) {
                if (!task.error && task.result) {
                    
                    GroupSelfie *groupSelfie = (GroupSelfie *)task.result;
                    
                    // Single Selfie will need to be redownloaded
                    NeedNetwork *needNetwork = [NeedNetwork sharedInstance];
                    [needNetwork removeDone:[SingleSelfie keyWithGroupSelfieId:groupSelfie.objectId]];
                    
                    [self manageGroupSelfie:groupSelfie inBackground:inBackground imageIsUpdated:YES];
                    
    #warning - if below iOS 10
                    if (!inBackground) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showPushForNotificationPayload:notificationPayload groupSelfie:groupSelfie andAction:^{
                                [self shouldNavigateToGroupSelfieViewControllerWithGroupSelfie:groupSelfie];
                            }];
                        });
                    }

                }
                return task;
            }];
            
        } else if ([[notificationPayload objectForKey:kPushPayloadTypeKey] isEqualToString:kPushPayloadTypeCommentedKey] ||
                   [[notificationPayload objectForKey:kPushPayloadTypeKey] isEqualToString:kPushPayloadTypeVotedKey] ||
                   [[notificationPayload objectForKey:kPushPayloadTypeKey] isEqualToString:kPushPayloadTypeReVotedKey]) {
            
            return [[[GroupSelfie groupSelfieWithNotificationPayload:notificationPayload] continueWithBlock:^id(BFTask *task) {
                if (!task.error && task.result) {
                    return [[Activity activityWithNotificationPayload:notificationPayload] continueWithBlock:^id(BFTask *activityTask) {
                        if (!activityTask.error && activityTask.result) {
                            return task;
                        } else {
                            return activityTask;
                        }
                    }];
                } else {
                    return task;
                }
            }] continueWithBlock:^id(BFTask *task) {
                if (!task.error && task.result) {
                    
                    GroupSelfie *groupSelfie = (GroupSelfie *) task.result;
                    [self manageGroupSelfie:groupSelfie inBackground:inBackground imageIsUpdated:NO];
                    
#warning - if below iOS 10
                    if (!inBackground) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showPushForNotificationPayload:notificationPayload groupSelfie:groupSelfie andAction:^{
                                NSString *zoomedId = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).zoomedGroupSelfieId;
                                if (!zoomedId || ![zoomedId isEqualToString:groupSelfie.objectId]) {
                                    [self shouldNavigateToGroupSelfieViewControllerWithGroupSelfie:groupSelfie];
                                }
                            }];
                        });
                    }
                    
                }
                return task;
            }];
          
        } else {
            BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
            [source setError:[NSError errorWithDomain:@"Wrong Option" code:1 userInfo:nil]];
            return source.task;
        }
        
    } else {
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        [source setError:[NSError errorWithDomain:@"Wrong Option" code:1 userInfo:nil]];
        return source.task;
    
    }
    
}

- (void)userDidPressRemoteNotification:(NSDictionary *)notificationPayload {
    
    if (notificationPayload) {
        
        if (![PFUser currentUser]) {
            return;
        }
        
        NSString *payloadKey = [notificationPayload objectForKey:kPushPayloadPayloadKey];
        if ([payloadKey isEqualToString:kPushPayloadPayloadActivityKey]) {
            NSString *typeKey = [notificationPayload objectForKey:kPushPayloadTypeKey];
            
            if ([typeKey isEqualToString:kPushPayloadTypeCreatedKey]) {
                return;
            } else if ([typeKey isEqualToString:kPushPayloadTypeParticipatedKey]) {
                return;
            } else if ([typeKey isEqualToString:kPushPayloadTypeCommentedKey]) {
                
                [[GroupSelfie groupSelfieWithId:[notificationPayload objectForKey:kPushPayloadToGroupSelfieIdKey] loadIfNeeded:YES] continueWithBlock:^id(BFTask *task) {
                    if (!task.error && task.result) {
                        GroupSelfie *groupSelfie = (GroupSelfie *)task.result;
                        [self shouldNavigateToGroupSelfieViewControllerWithGroupSelfie:groupSelfie];
                    }
                    return nil;
                }];
                
            }
            
        }
        
    }
    
}

- (void)shouldNavigateToGroupSelfieViewControllerWithGroupSelfie:(GroupSelfie *)groupSelfie {
    
    //[((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController popToRootViewControllerAnimated:NO];
    [self.pageViewController.streamNavigationController popToRootViewControllerAnimated:NO];
    
    GroupSelfieViewController *gsvc = [[GroupSelfieViewController alloc] init];
    
    gsvc.groupSelfie = groupSelfie;
    [[gsvc.activitiesTableViewController loadCache] continueWithBlock:^id(BFTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pageViewController.streamNavigationController pushViewController:gsvc animated:NO];
            
//            @try {
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//                [self.pageViewController.streamTableViewController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            } @catch (NSException * e) {
//                
//            }
            
        });
        return nil;
    }];
    
    [[groupSelfie addSeenIdCallNetwork:YES] continueWithBlock:^id(BFTask *task) {
        if (!task.error && task.result) {
            [self.pageViewController.streamTableViewController loadCache];
        }
        return nil;
    }];
    
}





- (void)showPushForNotificationPayload:(NSDictionary *)notificationPayload groupSelfie:(GroupSelfie *)groupSelfie andAction:(void (^)(void))action {

# warning - todo
    
    NSString *message;
    id messageId = [[[notificationPayload objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    if ([message isKindOfClass:[NSString class]]) message = messageId;
    
    NSString *showingId = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).showingGroupSelfieId;

    if (message && (!showingId || ![showingId isEqualToString:groupSelfie.objectId])) {
        AGPushNoteView *pushView = [[AGPushNoteView alloc] init];
        [self.pendingPushViews addObject:pushView];
        [pushView showWithNotificationMessage:message
                                       action:action
                                   completion:^{
            [pushView removeFromSuperview];
            [self.pendingPushViews removeObject:pushView];
            if (![self.pendingPushViews count]) [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
        }];
    }

}

- (void)manageGroupSelfie:(GroupSelfie *)groupSelfie inBackground:(BOOL)inBackground imageIsUpdated:(BOOL)imageIsUpdated {
    
    // Main
    
    if (![[groupSelfie getRelevantParticipatedIds] containsObject:[PFUser currentUser].objectId] && imageIsUpdated) {
        [self.pageViewController.mainTableViewController manageGroupSelfie:groupSelfie inBackground:inBackground];
    }
    
    // Stream
    
    for (UIViewController *viewController in self.pageViewController.streamNavigationController.viewControllers) {
        
        if ([viewController isKindOfClass:[StreamTableViewController class]]) {

            StreamTableViewController *stvc = (StreamTableViewController *)viewController;
            [stvc manageGroupSelfie:groupSelfie inBackground:inBackground];
            
        } else if ([viewController isKindOfClass:[NavigationViewController class]]) {
            NavigationViewController *navigationViewController = (NavigationViewController *)viewController;
            if ([navigationViewController.rootViewController isKindOfClass:[GroupSelfieViewController class]]) {
                GroupSelfieViewController *gsvc = (GroupSelfieViewController *)navigationViewController.rootViewController;
                if ([gsvc.groupSelfie.objectId isEqualToString:groupSelfie.objectId]) {
                    
                    if (imageIsUpdated) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            gsvc.groupSelfie = groupSelfie;
                        });
                    }
                    
    #warning - even though image is not updated in the case of a vote, need to refresh
                    
                    if (![[groupSelfie getRelevantSeenIds] containsObject:[PFUser currentUser].objectId]) {
                        [[groupSelfie addSeenIdCallNetwork:YES] continueWithBlock:^id(BFTask *task) {
                            [gsvc.activitiesTableViewController loadCache];
                            return nil;
                        }];
                    } else {
                        [gsvc.activitiesTableViewController loadCache];
                    }
                    
                }
            }
        }
    }
    
}

@end
