//
//  StreamTableViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ClassTableViewController.h"
#import "GroupSelfie.h"
#import "CameraViewController.h"

#import <MessageUI/MessageUI.h>

@protocol StreamTableViewControllerDelegate;

@interface StreamTableViewController : ClassTableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

- (void)manageGroupSelfie:(GroupSelfie *)groupSelfie inBackground:(BOOL)inBackground;

@property (nonatomic) BOOL isShowing;

@property (nonatomic, weak) id<StreamTableViewControllerDelegate, ClassTableViewControllerDelegate> delegate;

@end

@protocol StreamTableViewControllerDelegate <NSObject>
@optional

- (void)streamTableViewController:(StreamTableViewController *)streamTableVC didCountObjects:(int)count;
- (void)streamTableViewController:(StreamTableViewController *)streamTableVC didAddObject:(GroupSelfie *)groupSelfie;

@end
