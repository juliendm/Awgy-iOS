//
//  VerificationViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "VerificationViewController.h"
#import "BaseViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "PinsOnFile.h"
#import "SignUpViewController.h"

#import "AppDelegate.h"

static float const border = 25.0f;

static float const height = 42.0f;
static float const width = 245.0f;

static float const space = 5.0f;

static float const infoFontSize = 13.0f;
static float const labelFontSize = 22.0f;

@interface VerificationViewController ()

@property (nonatomic, strong) UITextField *verifCodeField;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation VerificationViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"VERIFICATION", nil);
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapBackButtonAction:)];
    [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.view.backgroundColor = [UIColor whiteColor];
    

    
    // Info
    
    NSString *info = NSLocalizedString(@"INFO_VERIF", nil);
    
    CGRect infoLabelFrame = [info boundingRectWithSize:CGSizeMake(self.view.frame.size.width-2.0f*border, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:infoFontSize] }
                                               context:nil];
    infoLabelFrame.origin.x = ceilf(0.5f*(self.view.frame.size.width-infoLabelFrame.size.width));
    infoLabelFrame.origin.y = border;
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:infoLabelFrame];
    infoLabel.text = info;
    infoLabel.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.font = [UIFont systemFontOfSize:infoFontSize];
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.numberOfLines = 0;
    [self.view addSubview:infoLabel];
    
    // Verification
    
    CGRect verifyCodeFieldFrame = CGRectZero;
    verifyCodeFieldFrame.origin.x = 0.5f*([UIScreen mainScreen].bounds.size.width - width);
    verifyCodeFieldFrame.origin.y = infoLabelFrame.origin.y + infoLabelFrame.size.height + 10.0f;
    verifyCodeFieldFrame.size.width = width;
    verifyCodeFieldFrame.size.height = height;
    self.verifCodeField = [[UITextField alloc] initWithFrame:verifyCodeFieldFrame];
    self.verifCodeField.placeholder = @"######";
    self.verifCodeField.font = [UIFont systemFontOfSize:labelFontSize];
    self.verifCodeField.textAlignment = NSTextAlignmentCenter;
    self.verifCodeField.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    self.verifCodeField.layer.borderWidth = 1.0f;
    self.verifCodeField.layer.borderColor = [[UIColor colorWithRed:lightGrayRed green:lightGrayGreen blue:lightGrayBlue alpha:1.0f] CGColor];
    self.verifCodeField.layer.cornerRadius = 5.0f;
    self.verifCodeField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.verifCodeField];
    
    CGRect verifyButtonFrame = CGRectZero;
    verifyButtonFrame.origin.x = verifyCodeFieldFrame.origin.x;
    verifyButtonFrame.origin.y = verifyCodeFieldFrame.origin.y + verifyCodeFieldFrame.size.height + space;
    verifyButtonFrame.size.width = width;
    verifyButtonFrame.size.height = height;
    
    UIButton *verifyButton = [[UIButton alloc] initWithFrame:verifyButtonFrame];
    verifyButton.backgroundColor = [UIColor whiteColor];
    verifyButton.layer.borderWidth = 1.0f;
    verifyButton.layer.borderColor = [[UIColor colorWithRed:lightGrayRed green:lightGrayGreen blue:lightGrayBlue alpha:1.0f] CGColor];
    verifyButton.layer.cornerRadius = 5.0f;
    NSAttributedString *attributedTitle =[[NSAttributedString alloc] initWithString:NSLocalizedString(@"VERIFY", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:labelFontSize], NSForegroundColorAttributeName:[UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f]}];
    [verifyButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [verifyButton addTarget:self action:@selector(didTapVerifyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verifyButton];
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).keyboardIsShowing = YES;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).keyboardIsShowing = NO;
}

- (void)dismissKeyboard {
    [self.verifCodeField resignFirstResponder];
}

- (void)didTapBackButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)didTapVerifyButtonAction:(id)sender {
    
    MBProgressHUD *hud;
    if (self.navigationController.view) {
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:0.5];
        hud.removeFromSuperViewOnHide = YES;
    }
    
    NSString *verifCode = [self.verifCodeField.text stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    
    if ([verifCode length] == 0) {
        
        if (hud) [hud hide:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                            message:NSLocalizedString(@"ERROR_NO_CODE", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else {
        
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        NSMutableString *randomString = [NSMutableString stringWithCapacity: 60];
        for (int i=0; i<60; i++) [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
        NSString *password = randomString;
        
        [PFCloud callFunctionInBackground:kUserFunctionKey
                           withParameters:@{kUserFunctionUsernameKey:self.username,
                                            kUserFunctionPasswordKey:password,
                                            kUserFunctionVerifCodeKey:verifCode}
                                    block:^(id object, NSError *error) {
            
            if (error) {
                
                if (hud) [hud hide:YES];
                NSString *message = [error.userInfo objectForKey:@"error"];
                BOOL needAddTag = [[[message componentsSeparatedByString:@"\n"] firstObject] isEqualToString:@"WRONG"];
                if (needAddTag) message = [[message componentsSeparatedByString:@"\n"] lastObject];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                    message:message
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles:nil];
                if (needAddTag) alertView.tag = 500;
                [alertView show];
                
            } else {
                
                if ([PFUser currentUser]) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.username forKey:kUserDefaultsUsernameKey];
                    
                    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                        
                        if (error) {
                            
                            if (hud) [hud hide:YES];
                            
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                                message:NSLocalizedString(@"ERROR", nil)
                                                                               delegate:nil
                                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                      otherButtonTitles:nil];
                            [alertView show];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        
                        } else {
                            
                            [PFUser logInWithUsernameInBackground:self.username
                                                         password:password
                                                            block:^(PFUser *user, NSError *error) {
                                                                
                                if (hud) [hud hide:YES];
                                
                                if (error) {
                                    
                                } else {
                                    
                                    [self.navigationController popViewControllerAnimated:YES];
                                    
                                }

                            }];
                            
                        }
                    }];
                    
                } else {
                
                    [PFUser logInWithUsernameInBackground:self.username
                                                 password:password
                                                    block:^(PFUser *user, NSError *error) {
                                                        if (error) {
                                                            
                                                            if (hud) [hud hide:YES];
                                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                                                                message:[error.userInfo objectForKey:@"error"]
                                                                                                               delegate:nil
                                                                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                                      otherButtonTitles:nil];

                                                            
                                                            [alertView show];
                                                            
                                                        } else {
                                                            
                                                            // Associate the device with a user
                                                            PFInstallation *installation = [PFInstallation currentInstallation];
                                                            installation[@"user"] = [PFUser currentUser];
                                                            
                                                            [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                                if (error) {
                                                                    [PFUser logOut];
                                                                    if (hud) [hud hide:YES];
                                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                                                                        message:NSLocalizedString(@"ERROR_REINSTALL", nil)
                                                                                                                       delegate:nil
                                                                                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                                              otherButtonTitles:nil];
                                                                    [alertView show];
                                                                } else {
                                                                    
                                                                    if (hud) [hud hide:YES];
                                                                    
                                                                    PinsOnFile *pinsOnFile = [PinsOnFile sharedInstance];
                                                                    [pinsOnFile initiate];
                                                                    
                                                                    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController firstArrival:YES];
                                                                    
                                                                }
                                                            }];
                                                        }
                                                    }];

                    
                }
            }
            
        }];
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag != 500) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Notification center

- (void)keyboardWillShow:(NSNotification*)note {
    
    [self.view addGestureRecognizer:self.tap];
}

- (void)keyboardWillHide:(NSNotification*)note {
    
    [self.view removeGestureRecognizer:self.tap];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
