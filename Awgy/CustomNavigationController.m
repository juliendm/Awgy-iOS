//
//  CustomNavigationController.m
//  Awgy
//
//  Copyright 2015 Parse, Inc. All rights reserved.
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController

-(BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
