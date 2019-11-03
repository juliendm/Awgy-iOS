//
//  ImageViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "GroupSelfie.h"
#import "PFImageViewExtended.h"

@interface ImageViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) GroupSelfie *groupSelfie;
@property (nonatomic, strong) PFImageViewExtended *imageView;

@property (nonatomic) NSInteger index;

- (void)resetScrollViewForFrame:(CGRect)frame;

@end
