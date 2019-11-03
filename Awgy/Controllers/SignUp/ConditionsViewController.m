//
//  ConditionsViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ConditionsViewController.h"

#import <Parse/Parse.h>
#import "Constants.h"

static float const border = 15.0f;

static float const width = 245.0f;
static float const height = 42.0f;

static float const infoFontSize = 16.0f;
static float const labelFontSize = 22.0f;

static float const vspace = 1.0f;

@interface ConditionsViewController ()

@end

@implementation ConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"CONDITIONS_CHANGED", nil);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Conditions
    
    UIColor *color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    
    NSString *conditions = @"Please review carefully our new";
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
    
    conditionsLabelFrame.origin.x = 0.5f*(self.view.frame.size.width-conditionsLabelFrame.size.width);
    conditionsLabelFrame.origin.y = 50.0f;
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsLabelFrame];
    conditionsLabel.text = conditions;
    conditionsLabel.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    conditionsLabel.textAlignment = NSTextAlignmentCenter;
    conditionsLabel.font = [UIFont systemFontOfSize:infoFontSize];
    conditionsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    conditionsLabel.numberOfLines = 0;
    [self.view addSubview:conditionsLabel];
    
    termsOfUseButtonFrame.origin.x = 0.5f*(self.view.frame.size.width-termsOfUseButtonFrame.size.width);
    termsOfUseButtonFrame.origin.y = conditionsLabelFrame.origin.y + conditionsLabelFrame.size.height + vspace;
    UIButton *termsOfUseButton = [[UIButton alloc] initWithFrame:termsOfUseButtonFrame];
    [termsOfUseButton setAttributedTitle:termsOfUse forState:UIControlStateNormal];
    [termsOfUseButton addTarget:self action:@selector(didTapTermsOfUseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:termsOfUseButton];
    
    andLabelFrame.origin.x = 0.5f*(self.view.frame.size.width-andLabelFrame.size.width);
    andLabelFrame.origin.y = termsOfUseButtonFrame.origin.y + termsOfUseButtonFrame.size.height + vspace;
    UILabel *andLabel = [[UILabel alloc] initWithFrame:andLabelFrame];
    andLabel.text = and;
    andLabel.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    andLabel.textAlignment = NSTextAlignmentCenter;
    andLabel.font = [UIFont systemFontOfSize:infoFontSize];
    andLabel.lineBreakMode = NSLineBreakByWordWrapping;
    andLabel.numberOfLines = 0;
    [self.view addSubview:andLabel];
    
    privacyPolicyButtonFrame.origin.x = 0.5f*(self.view.frame.size.width-privacyPolicyButtonFrame.size.width);
    privacyPolicyButtonFrame.origin.y = andLabelFrame.origin.y + andLabelFrame.size.height + vspace;
    UIButton *privacyPolicyButton = [[UIButton alloc] initWithFrame:privacyPolicyButtonFrame];
    [privacyPolicyButton setAttributedTitle:privacyPolicy forState:UIControlStateNormal];
    [privacyPolicyButton addTarget:self action:@selector(didTapPrivacyPolicyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:privacyPolicyButton];
    
    CGRect acceptButtonFrame = CGRectZero;
    acceptButtonFrame.origin.x = 0.5f*(self.view.frame.size.width - width);
    acceptButtonFrame.origin.y = privacyPolicyButtonFrame.origin.y + privacyPolicyButtonFrame.size.height + 30.0f;
    acceptButtonFrame.size.width = width;
    acceptButtonFrame.size.height = height;
    
    UIButton *acceptButton = [[UIButton alloc] initWithFrame:acceptButtonFrame];
    acceptButton.backgroundColor = [UIColor whiteColor];
    acceptButton.layer.borderWidth = 1.0f;
    acceptButton.layer.borderColor = [[UIColor colorWithRed:lightGrayRed green:lightGrayGreen blue:lightGrayBlue alpha:1.0f] CGColor];
    acceptButton.layer.cornerRadius = 5.0f;
    NSAttributedString *attributedTitle =[[NSAttributedString alloc] initWithString:NSLocalizedString(@"ACCEPT", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:labelFontSize], NSForegroundColorAttributeName:[UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f]}];
    [acceptButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [acceptButton addTarget:self action:@selector(didTapAcceptButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:acceptButton];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (void)didTapTermsOfUseButtonAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://awgy.com/page-terms-of-use.html"];
    [[UIApplication sharedApplication] openURL:url];
}


- (void)didTapPrivacyPolicyButtonAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://awgy.com/page-privacy-policy.html"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didTapAcceptButtonAction:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"I accept the new Terms Of Use and Privacy Policy"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"CONFIRM", nil),nil];
    alertView.tag = 100;
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            
            [PFCloud callFunctionInBackground:kUserFunctionAcceptConditionsKey withParameters:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
    
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
