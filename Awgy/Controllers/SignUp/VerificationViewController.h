//
//  VerificationViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface VerificationViewController : UIViewController <UIAlertViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) NSString *username;

@end
