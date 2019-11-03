//
//  AppDelegate.m
//  Awgy
//
//  Copyright 2015 Parse, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraViewController.h"
#import "GroupSelfieViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "PhoneBook.h"
#import <Bolts/BFTask.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"awgy";
        configuration.clientKey = @"...";
        configuration.server = @"https://api.awgy.com/parse";
        configuration.localDatastoreEnabled = true;
    }]];
    
    [self setupAppearance];
    
    if(SYSTEM_VERSION_LESS_THAN(@"10.0")){
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
    } else {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [application registerForRemoteNotifications];
            }
        }];

    }
    

    
    [Fabric with:@[[Crashlytics class]]];
    
    self.baseViewController = [[BaseViewController alloc] init];
    
    self.rootNavigationController = [[CustomNavigationController alloc] initWithRootViewController:self.baseViewController];
    self.rootNavigationController.navigationBar.tintColor = [UIColor blackColor];
    self.rootNavigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.rootNavigationController.navigationBar.translucent = NO;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.rootNavigationController;
    [self.window makeKeyAndVisible];
    
    //self.keyboardIsShowing = NO;
    self.showingGroupSelfieId = nil;
    self.zoomedGroupSelfieId = nil;
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self.baseViewController userDidPressRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) currentInstallation[@"user"] = currentUser;
    currentInstallation[@"deviceVersion"] = [[UIDevice currentDevice] systemVersion];
    [currentInstallation saveInBackground];
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        
        //[[[UIAlertView alloc] initWithTitle:@"Notice" message:@"The App won't work properly without Notifications; Please go to Settings > Notifications > Awgy, and allow for Notifications. Then close and start the app again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)resetPageViewControllerDataSource {
    self.baseViewController.pageViewController.dataSource = self.baseViewController.pageViewController;
}

- (void)removePageViewControllerDataSource {
    self.baseViewController.pageViewController.dataSource = nil;
}








-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{

    // Choose if shows Alert while in App for iOS 10
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (!self.showingGroupSelfieId || ![self.showingGroupSelfieId isEqualToString:[userInfo objectForKey:kPushPayloadToGroupSelfieIdKey]]) {
        completionHandler(UNNotificationPresentationOptionAlert);
    } else {
        completionHandler(UNNotificationPresentationOptionNone);
    }
    
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    
    NSLog(@"log_awgy: Did Click iOS 10");
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self.baseViewController userDidPressRemoteNotification:userInfo];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    if(application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"log_awgy: Did Click iOS 8-9");
        
        [self.baseViewController userDidPressRemoteNotification:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData); // ALSO; NODATA, FAILED
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"log_awgy: Background");
        
        [[self.baseViewController applicationDidReceiveRemoteNotification:userInfo inBackground:YES] continueWithBlock:^id(BFTask *task) {
            if (!task.error) {
                completionHandler(UIBackgroundFetchResultNewData);
            } else {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            return nil;
        }];
        
    } else if (application.applicationState == UIApplicationStateActive) {
        
        NSLog(@"log_awgy: Active");
        
        [[self.baseViewController applicationDidReceiveRemoteNotification:userInfo inBackground:NO] continueWithBlock:^id(BFTask *task) {
            if (!task.error) {
                completionHandler(UIBackgroundFetchResultNewData);
            } else {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            return nil;
        }];
        
    }

}













- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateApplicationWillResignActiveNotification object:nil userInfo:nil];
    
    [[PhoneBook sharedInstance] setReloaded:NO];

    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSDate *currentDate= [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"backgroundDate"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateApplicationDidEnterBackgroundNotification object:nil userInfo:nil];
    
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateApplicationWillEnterForegroundNotification object:nil userInfo:nil];
    
    NSDate *dateWhenAppGoesBg= (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundDate"];
    NSTimeInterval timeSpentInBackground = [[NSDate date] timeIntervalSinceDate:dateWhenAppGoesBg];
    timeSpentInBackground = round(timeSpentInBackground*10.0)/10.0;
    if (timeSpentInBackground < 0.0) timeSpentInBackground = 1000.0; // user has changed clock time, cancel groupSelfie
    
    NSLog(@"Spent in background: %f",timeSpentInBackground);
    
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateApplicationDidBecomeActiveNotification object:nil userInfo:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
    
    NSLog(@"applicationDidBecomeActive");
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    NSLog(@"applicationWillTerminate");
}















- (void)setupAppearance {
    
    // Navigation Bar
    
    [UINavigationBar appearance].tintColor = [UIColor blackColor];
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent = NO;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
}


@end
