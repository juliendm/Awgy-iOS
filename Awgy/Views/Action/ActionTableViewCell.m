//
//  ActionTableViewCell.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ActionTableViewCell.h"

CGFloat const ActionTableViewCellActionLabelFontSize = 22.0f;

static float const bckdgBorder = 5.0f;

@interface ActionTableViewCell ()

@property (nonatomic, strong) UIView *bckgdView;

@end

@implementation ActionTableViewCell

#pragma mark - Class

+ (CGSize)sizeThatFits:(CGSize)boundingSize {
    CGSize size = CGSizeZero;
    size.height = 85.0f;
    return size;
}

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _bckgdView = [[UIView alloc] init];
        _bckgdView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
        _bckgdView.layer.cornerRadius = 5.0f;
        _bckgdView.clipsToBounds = YES;
        [self addSubview:_bckgdView];
        
        _actionLabel = [[UILabel alloc] init];
        _actionLabel.font = [UIFont systemFontOfSize:ActionTableViewCellActionLabelFontSize];
        _actionLabel.textColor = [UIColor blackColor];
        [_bckgdView addSubview:_actionLabel];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Background
    CGRect bckgdViewFrame = CGRectMake(bckdgBorder, 0.0f, self.frame.size.width - 2.0f*bckdgBorder, self.frame.size.height - bckdgBorder);
    self.bckgdView.frame = bckgdViewFrame;
    
    // Action
    CGRect actionLabelFrame = [self.actionLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{ NSFontAttributeName : self.actionLabel.font }
                                                                    context:nil];
    actionLabelFrame.origin.x = 0.5f*(bckgdViewFrame.size.width - actionLabelFrame.size.width);
    actionLabelFrame.origin.y = 0.5f*(bckgdViewFrame.size.height - actionLabelFrame.size.height);
    self.actionLabel.frame = actionLabelFrame;
    
}

@end
