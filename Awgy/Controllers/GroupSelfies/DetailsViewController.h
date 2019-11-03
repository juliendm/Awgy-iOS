//
//  DetailsViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupSelfie.h"
#import "PhoneBook.h"

@interface DetailsViewController : UITableViewController <ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate>

@property (nonatomic, strong) GroupSelfie *groupSelfie;

@end
