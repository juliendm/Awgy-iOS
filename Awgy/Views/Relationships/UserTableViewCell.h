//
//  UserTableViewCell.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PhoneBook.h"

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, weak) NSString *username;
@property (nonatomic, weak) NSNumber *number;

+ (CGSize)sizeThatFits:(CGSize)boundingSize forUsername:(NSString *)username withNumber:(NSNumber *)number;
- (void)updateForUsername:(NSString *)username withNumber:(NSNumber *)number;

- (void)checkCell;
- (void)uncheckCell;

@end

