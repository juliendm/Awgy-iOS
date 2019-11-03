//
//  NavigationViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationViewController : UIViewController

@property (nonatomic, strong) UIViewController *rootViewController;

- (id)initWithRootViewController:(UIViewController *)viewController;
- (void)didTapBack;

@end
