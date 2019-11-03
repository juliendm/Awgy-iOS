//
//  MainTableViewCell.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GroupSelfie.h"
#import "PhoneBook.h"

#import "PFTableViewCellExtended.h"

@interface MainTableViewCell : PFTableViewCellExtended

@property (nonatomic, weak) GroupSelfie *groupSelfie;

+ (CGSize)sizeThatFits:(CGSize)boundingSize forGroupSelfie:(GroupSelfie *)groupSelfie;
- (void)updateForGroupSelfie:(GroupSelfie *)groupSelfie;

@end

