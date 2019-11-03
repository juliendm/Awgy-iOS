//
//  EditViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GroupSelfie.h"

@protocol EditViewControllerDelegate;

@interface EditViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) GroupSelfie *groupSelfie;
@property (nonatomic) BOOL saveOption;

@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, weak) id<EditViewControllerDelegate> delegate;

@end

@protocol EditViewControllerDelegate <NSObject>
@optional

- (void)editViewController:(EditViewController *)editViewController didSelectFilter:(NSString *)filterName;

@end
