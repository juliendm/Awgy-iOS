//
//  SingleSelfiesTableViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ClassTableViewController.h"

#import "GroupSelfie.h"

@interface SingleSelfiesTableViewController : ClassTableViewController

@property (nonatomic, strong) GroupSelfie *groupSelfie;
@property (nonatomic, strong) NSMutableArray *imageViewControllers;

@end