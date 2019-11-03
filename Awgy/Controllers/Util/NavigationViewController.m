//
//  NavigationViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "NavigationViewController.h"
#import "CustomNavigationController.h"

#import "AppDelegate.h"

@interface NavigationViewController()

@property (nonatomic, strong) id<UIPageViewControllerDataSource> savedDataSource;

@end

@implementation NavigationViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        
        _rootViewController = rootViewController;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:rootViewController];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBackButtonAction:)];
        [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        rootViewController.navigationItem.leftBarButtonItem = backButton;
        
        [self.view addSubview:navigationController.view];
        [self addChildViewController:navigationController];
        [navigationController didMoveToParentViewController:self];
        
    }
    return self;
}

- (void)viewDidLoad {

    self.savedDataSource = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.dataSource;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.dataSource = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}

- (void)didTapBackButtonAction:(id)sender {
    [self didTapBack];
}

- (void)didTapBack {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.dataSource = self.savedDataSource;
    [self.navigationController popViewControllerAnimated:YES];
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
