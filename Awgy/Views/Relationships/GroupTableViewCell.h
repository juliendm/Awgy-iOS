//
//  GroupTableViewCell.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GroupTableViewCell : UITableViewCell

@property (nonatomic, weak) NSString *name;
@property (nonatomic, weak) NSNumber *number;

- (void)updateForName:(NSString *)name withNumber:(NSNumber *)number;

@end
