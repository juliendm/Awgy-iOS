//
//  SetUpTableViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ClassTableViewController.h"
#import "GroupSelfie.h"

#import <MessageUI/MessageUI.h>

@interface SetUpTableViewController : ClassTableViewController <UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) GroupSelfie *groupSelfie;

@end
