//
//  SignUpViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "SignUpViewController.h"
#import "VerificationViewController.h"

#import "CustomNavigationController.h"

#import "NBPhoneNumberUtil.h"
#import "Constants.h"

#import <Parse/Parse.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


static float const border = 25.0f;

static float const height = 42.0f;

static float const plusWidth = 18.0f;
static float const codeWidth = 60.0f;
static float const numberWidth = 180.0f;

static float const space = 5.0f;

static float const infoFontSize = 13.0f;
static float const labelFontSize = 22.0f;


@interface SignUpViewController ()

@property (nonatomic, strong) UILabel *countryCodeField;
@property (nonatomic, strong) UITextField *nationalNumberField;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, strong) CountryTableViewController *countryTableViewController;

@end

@implementation SignUpViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CountryCodeCountryCodeHasBeenUpdatedNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        
        _countryTableViewController = [[CountryTableViewController alloc] init];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(didTapCancelButtonAction:)];
        _countryTableViewController.navigationItem.leftBarButtonItem = cancelButton;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, 200, 35);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [[UIImage imageNamed:@"awgy_styled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Info
    
    NSString *info = NSLocalizedString(@"INFO_SIGNUP", nil);
    
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
    
    // Phone Number
    
    CGRect plusLabelFrame = CGRectZero;
    plusLabelFrame.origin.x = ceilf(0.5f*(self.view.frame.size.width - (codeWidth + space + numberWidth)) - plusWidth);
    plusLabelFrame.origin.y = infoLabelFrame.origin.y + infoLabelFrame.size.height + 10.0f;
    plusLabelFrame.size.width = plusWidth;
    plusLabelFrame.size.height = height;
    UILabel *plusLabel = [[UILabel alloc] initWithFrame:plusLabelFrame];
    plusLabel.text = @"+";
    plusLabel.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    plusLabel.textAlignment = NSTextAlignmentCenter;
    plusLabel.font = [UIFont systemFontOfSize:22.0f];
    [self.view addSubview:plusLabel];
    
    CGRect countryCodeFieldFrame = CGRectZero;
    countryCodeFieldFrame.origin.x = plusLabelFrame.origin.x + plusLabelFrame.size.width;
    countryCodeFieldFrame.origin.y = plusLabelFrame.origin.y;
    countryCodeFieldFrame.size.width = codeWidth;
    countryCodeFieldFrame.size.height = height;
    self.countryCodeField = [[UILabel alloc] initWithFrame:countryCodeFieldFrame];
    self.countryCodeField.backgroundColor = [UIColor whiteColor];
    self.countryCodeField.layer.borderWidth = 1.0f;
    self.countryCodeField.layer.borderColor = [[UIColor colorWithRed:lightGrayRed green:lightGrayGreen blue:lightGrayBlue alpha:1.0f] CGColor];
    self.countryCodeField.layer.cornerRadius = 5.0f;
    self.countryCodeField.font = [UIFont systemFontOfSize:labelFontSize];
    self.countryCodeField.textAlignment = NSTextAlignmentCenter;
    self.countryCodeField.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    [self.view addSubview:self.countryCodeField];
    UITapGestureRecognizer *countryCodeFieldGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCountryCodeField:)];
    [self.countryCodeField addGestureRecognizer:countryCodeFieldGestureRecognizer];
    self.countryCodeField.userInteractionEnabled = YES;


    CGRect nationalNumberFieldFrame = CGRectZero;
    nationalNumberFieldFrame.origin.x = countryCodeFieldFrame.origin.x + countryCodeFieldFrame.size.width + space;
    nationalNumberFieldFrame.origin.y = countryCodeFieldFrame.origin.y;
    nationalNumberFieldFrame.size.width = numberWidth;
    nationalNumberFieldFrame.size.height = height;
    self.nationalNumberField = [[UITextField alloc] initWithFrame:nationalNumberFieldFrame];
    self.nationalNumberField.backgroundColor = [UIColor whiteColor];
    self.nationalNumberField.layer.borderWidth = 1.0f;
    self.nationalNumberField.layer.borderColor = [[UIColor colorWithRed:lightGrayRed green:lightGrayGreen blue:lightGrayBlue alpha:1.0f] CGColor];
    self.nationalNumberField.layer.cornerRadius = 5.0f;
    self.nationalNumberField.placeholder = NSLocalizedString(@"PHONE_NUMBER", nil);
    self.nationalNumberField.font = [UIFont systemFontOfSize:labelFontSize];
    self.nationalNumberField.textAlignment = NSTextAlignmentCenter;
    self.nationalNumberField.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    self.nationalNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.nationalNumberField];
    
    // Button
    
    CGRect signUpButtonFrame = CGRectZero;
    signUpButtonFrame.origin.y = plusLabelFrame.origin.y + plusLabelFrame.size.height + space;
    signUpButtonFrame.origin.x = countryCodeFieldFrame.origin.x;
    signUpButtonFrame.size.width = nationalNumberFieldFrame.origin.x + nationalNumberFieldFrame.size.width - countryCodeFieldFrame.origin.x;
    signUpButtonFrame.size.height = height;
    
    UIButton *signUpButton = [[UIButton alloc] initWithFrame:signUpButtonFrame];
    signUpButton.backgroundColor = [UIColor whiteColor];
    signUpButton.layer.borderWidth = 1.0f;
    signUpButton.layer.borderColor = [[UIColor colorWithRed:lightGrayRed green:lightGrayGreen blue:lightGrayBlue alpha:1.0f] CGColor];
    signUpButton.layer.cornerRadius = 5.0f;
    NSAttributedString *attributedTitle =[[NSAttributedString alloc] initWithString:NSLocalizedString(@"SIGNUP", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:labelFontSize], NSForegroundColorAttributeName:[UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f]}];
    [signUpButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [signUpButton addTarget:self action:@selector(didTapSignUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    
    // Conditions
    
    UIColor *color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
 
    float hspace = 5.0f;
    float vspace = 1.0f;
    
    NSString *conditions = NSLocalizedString(@"CONDITIONS_SIGNUP", nil);
    CGRect conditionsLabelFrame = [conditions boundingRectWithSize:CGSizeMake(self.view.frame.size.width-2.0f*border, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:infoFontSize] }
                                               context:nil];

    NSMutableAttributedString *termsOfUse = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"TERMS_OF_USE", nil) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:infoFontSize], NSForegroundColorAttributeName:color}];
    CGRect termsOfUseButtonFrame = [termsOfUse boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                            context:nil];
    NSString *and = NSLocalizedString(@"AND", nil);
    CGRect andLabelFrame = [and boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:infoFontSize] }
                                             context:nil];
    NSMutableAttributedString *privacyPolicy = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"PRIVACY_POLICY", nil) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:infoFontSize], NSForegroundColorAttributeName:color}];
    CGRect privacyPolicyButtonFrame = [privacyPolicy boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                                  context:nil];
    
    if (termsOfUseButtonFrame.size.width + andLabelFrame.size.width + privacyPolicyButtonFrame.size.width + 2.0f*hspace < self.view.frame.size.width - 2.0f*border) {
    
        conditionsLabelFrame.origin.x = 0.5f*(self.view.frame.size.width-conditionsLabelFrame.size.width);
        conditionsLabelFrame.origin.y = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - conditionsLabelFrame.size.height - vspace - termsOfUseButtonFrame.size.height - 15.0;
        
        termsOfUseButtonFrame.origin.x = 0.5f*(self.view.frame.size.width-termsOfUseButtonFrame.size.width-andLabelFrame.size.width-privacyPolicyButtonFrame.size.width-2.0f*hspace);
        termsOfUseButtonFrame.origin.y = conditionsLabelFrame.origin.y + conditionsLabelFrame.size.height + vspace;
        
        andLabelFrame.origin.x = termsOfUseButtonFrame.origin.x + termsOfUseButtonFrame.size.width + hspace;
        andLabelFrame.origin.y = termsOfUseButtonFrame.origin.y;
        
        privacyPolicyButtonFrame.origin.x = andLabelFrame.origin.x + andLabelFrame.size.width + hspace;
        privacyPolicyButtonFrame.origin.y = termsOfUseButtonFrame.origin.y;
        
    } else {
    
        conditionsLabelFrame.origin.x = 0.5f*(self.view.frame.size.width-conditionsLabelFrame.size.width);
        conditionsLabelFrame.origin.y = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - conditionsLabelFrame.size.height - vspace - termsOfUseButtonFrame.size.height - vspace - privacyPolicy.size.height - 15.0;
        
        termsOfUseButtonFrame.origin.x = 0.5f*(self.view.frame.size.width-termsOfUseButtonFrame.size.width-andLabelFrame.size.width-hspace);
        termsOfUseButtonFrame.origin.y = conditionsLabelFrame.origin.y + conditionsLabelFrame.size.height + vspace;
        
        andLabelFrame.origin.x = termsOfUseButtonFrame.origin.x + termsOfUseButtonFrame.size.width + hspace;
        andLabelFrame.origin.y = termsOfUseButtonFrame.origin.y;
        
        privacyPolicyButtonFrame.origin.x = 0.5f*(self.view.frame.size.width-privacyPolicyButtonFrame.size.width);
        privacyPolicyButtonFrame.origin.y = termsOfUseButtonFrame.origin.y + termsOfUseButtonFrame.size.height + vspace;
        
    }
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsLabelFrame];
    conditionsLabel.text = conditions;
    conditionsLabel.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    conditionsLabel.textAlignment = NSTextAlignmentCenter;
    conditionsLabel.font = [UIFont systemFontOfSize:infoFontSize];
    conditionsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    conditionsLabel.numberOfLines = 0;
    [self.view addSubview:conditionsLabel];

    UIButton *termsOfUseButton = [[UIButton alloc] initWithFrame:termsOfUseButtonFrame];
    [termsOfUseButton setAttributedTitle:termsOfUse forState:UIControlStateNormal];
    [termsOfUseButton addTarget:self action:@selector(didTapTermsOfUseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:termsOfUseButton];

    UILabel *andLabel = [[UILabel alloc] initWithFrame:andLabelFrame];
    andLabel.text = and;
    andLabel.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    andLabel.textAlignment = NSTextAlignmentCenter;
    andLabel.font = [UIFont systemFontOfSize:infoFontSize];
    andLabel.lineBreakMode = NSLineBreakByWordWrapping;
    andLabel.numberOfLines = 0;
    [self.view addSubview:andLabel];

    UIButton *privacyPolicyButton = [[UIButton alloc] initWithFrame:privacyPolicyButtonFrame];
    [privacyPolicyButton setAttributedTitle:privacyPolicy forState:UIControlStateNormal];
    [privacyPolicyButton addTarget:self action:@selector(didTapPrivacyPolicyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:privacyPolicyButton];
    
    // Prefill
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUsernameKey];
    if (username) {
        NSString *nationalNumber = nil;
        NSNumber *countryCode = [phoneUtil extractCountryCode:username nationalNumber:&nationalNumber];
        NSArray *iso = [phoneUtil regionCodeFromCountryCode:countryCode];
        if(iso && [iso count] && [iso firstObject]) self.countryTableViewController.selectedCountryCode = [iso firstObject];
        self.countryCodeField.text = [countryCode stringValue];
        self.nationalNumberField.text = nationalNumber;
    } else {
        CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
        CTCarrier *carrier = network_Info.subscriberCellularProvider;
        NSString *countryCode = [phoneUtil countryCodeFromRegionCode:[carrier.isoCountryCode uppercaseString]];
        if (countryCode) {
            self.countryCodeField.text = countryCode;
            if (carrier.isoCountryCode) self.countryTableViewController.selectedCountryCode = [carrier.isoCountryCode uppercaseString];
        } else {
            self.countryCodeField.text = @"1";
            self.countryTableViewController.selectedCountryCode =  @"US";
        }
    }
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countryCodeHasBeenUpdatedNotification:) name:CountryCodeCountryCodeHasBeenUpdatedNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)dismissKeyboard {
    [self.nationalNumberField resignFirstResponder];
}

- (void)didTapCountryCodeField:(UITapGestureRecognizer *)recognizer {
    
    [self dismissKeyboard];
    
    CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:self.countryTableViewController];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self presentViewController:navigationController animated:YES completion:nil];

}

- (void)countryCodeHasBeenUpdatedNotification:(NSNotification *)note {
    self.countryCodeField.text = [[note userInfo] objectForKey:@"countryCode"];
}

- (void)didTapCancelButtonAction:(id)sender {
    [self.countryTableViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapSignUpButtonAction:(id)sender {
    
    [self dismissKeyboard];
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSString *nationalNumber = [[self.nationalNumberField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSNumber *countryCode = [NSNumber numberWithInteger:[[[self.countryCodeField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue]];
    NSString *regionCode = [phoneUtil getRegionCodeForCountryCode:countryCode];

    NSError *error = nil;
    NBPhoneNumber *number = [phoneUtil parse:nationalNumber defaultRegion:regionCode error:&error];
    
    if (error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                    message:NSLocalizedString(@"ERROR_PHONE_NUMBER", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else {

        self.username = [[phoneUtil format:number numberFormat:NBEPhoneNumberFormatE164 error:&error] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.username forKey:kUserDefaultsUsernameKey];
        
        [PFCloud callFunctionInBackground:kVerificationFunctionKey
                           withParameters:@{kVerificationFunctionPhoneNumberKey:self.username}
                                    block:^(id object, NSError *error) {
//                                        if (error) {
//                                            NSString *message = [error.userInfo objectForKey:@"error"];
//                                            BOOL needAddTag = [[[message componentsSeparatedByString:@"\n"] firstObject] isEqualToString:@"ACTIVE"];
//                                            if (needAddTag) message = [[message componentsSeparatedByString:@"\n"] lastObject];
//                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
//                                                                                                message:message
//                                                                                               delegate:self
//                                                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                                                                      otherButtonTitles:nil];
//                                            if (needAddTag) alertView.tag = 200;
//                                            [alertView show];
//                                        } else {
                                            VerificationViewController *vvc = [[VerificationViewController alloc] init];
                                            vvc.username = self.username;
                                            [self.navigationController pushViewController:vvc animated:YES];
//                                        }
                                    }];
        
        
    }

    
}


- (void)didTapTermsOfUseButtonAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://awgy.com/page-terms-of-use.html"];
    [[UIApplication sharedApplication] openURL:url];
}


- (void)didTapPrivacyPolicyButtonAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://awgy.com/page-privacy-policy.html"];
    [[UIApplication sharedApplication] openURL:url];
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
