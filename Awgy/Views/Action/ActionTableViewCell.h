//
//  ActionTableViewCell.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ActionTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *actionLabel;

+ (CGSize)sizeThatFits:(CGSize)boundingSize;

@end

