//
//  MainTableViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ClassTableViewController.h"
#import "GroupSelfie.h"

@protocol MainTableViewControllerDelegate;

@interface MainTableViewController : ClassTableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) UIDeviceOrientation deviceOrientation;

@property (nonatomic, weak) id<MainTableViewControllerDelegate, ClassTableViewControllerDelegate> delegate;

- (void)manageGroupSelfie:(GroupSelfie *)groupSelfie inBackground:(BOOL)inBackground;

@end

@protocol MainTableViewControllerDelegate <NSObject>
@optional

- (void)mainTableViewController:(MainTableViewController *)mainTVC didSnapGroupSelfie:(GroupSelfie *)groupSelfie;

@end
