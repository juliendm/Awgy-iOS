//
//  LibraryCollectionViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GroupSelfie.h"

@interface LibraryCollectionViewController : UICollectionViewController <UICollectionViewDataSource>

@property (nonatomic, strong) GroupSelfie *groupSelfie;

- (void)loadRecentPictures;

@end
