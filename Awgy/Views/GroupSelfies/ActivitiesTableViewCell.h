//
//  ActivitiesTableViewCell.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Activity.h"
#import "PhoneBook.h"

@interface ActivitiesTableViewCell : UITableViewCell

+ (CGSize)sizeThatFits:(CGSize)boundingSize forActivity:(Activity *)activity onGroupSelfie:(GroupSelfie *)groupSelfie;
- (void)updateForActivity:(Activity *)activity onGroupSelfie:(GroupSelfie *)groupSelfie;

@end

