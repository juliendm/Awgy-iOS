//
//  SwipeBackViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeBackViewController : UIViewController <UINavigationControllerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *popRecognizer;

@end
