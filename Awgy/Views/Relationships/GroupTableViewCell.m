//
//  GroupTableViewCell.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "GroupTableViewCell.h"
#import "Constants.h"

CGFloat const GroupTableViewCellNameLabelFontSize = 18.0f;
CGFloat const GroupTableViewCellNumberLabelFontSize = 18.0f;

static float const borderSize = 13.0f;
static float const borderSizeNumber = 13.0f;

@interface GroupTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation GroupTableViewCell

#pragma mark - Class

+ (CGSize)sizeThatFits:(CGSize)boundingSize forUsername:(NSString *)username withNumber:(NSNumber *)number {
    
    float current_y = 0.0f;
    
    CGSize size = CGSizeZero;
    size.height = current_y + borderSizeNumber;
    return size;
    
}

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        UIColor *color = [UIColor blackColor];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = color;
        _nameLabel.font = [UIFont systemFontOfSize:GroupTableViewCellNameLabelFontSize];
        [self addSubview:_nameLabel];
        
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f];
        _numberLabel.textAlignment = NSTextAlignmentRight;
        _numberLabel.font = [UIFont systemFontOfSize:GroupTableViewCellNumberLabelFontSize];
        [self addSubview:_numberLabel];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float nameWidth = ceilf(0.75f*(self.frame.size.width-2.0f*borderSize));
    
    // Name
    CGRect nameLabelFrame = [self.nameLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: self.nameLabel.font}
                                                              context:nil];
    nameLabelFrame.size.width = nameWidth;
    nameLabelFrame.origin.x = borderSize;
    nameLabelFrame.origin.y = borderSizeNumber;
    
    self.nameLabel.frame = nameLabelFrame;
    
    // Number
    if (self.numberLabel.text) {
        
        CGRect numberLabelFrame = CGRectZero;
        numberLabelFrame.origin.x = nameLabelFrame.origin.x + nameWidth;
        numberLabelFrame.origin.y = borderSizeNumber;
        numberLabelFrame.size.width = self.frame.size.width - 2.0f*borderSize - nameWidth;
        numberLabelFrame.size.height = nameLabelFrame.size.height;
        
        self.numberLabel.frame = numberLabelFrame;
        
    } else {
        
        self.numberLabel.frame = CGRectZero;
        
    }
    
}

#pragma mark - Update

- (void)updateForName:(NSString *)name withNumber:(NSNumber *)number {
    
    _name = name;
    _number = number;
    
    if (name) {
        self.nameLabel.text = name;
        self.numberLabel.text = [number stringValue];
    } else {
        self.nameLabel.text = nil;
        self.numberLabel.text = nil;
    }
    
    [self setNeedsLayout];
}

- (void)checkCell {
    
    NSTextAttachment *checkAttachment = [[NSTextAttachment alloc] init];
    checkAttachment.image = [[UIImage imageNamed:@"check_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    checkAttachment.bounds = CGRectMake(0, 0, 20.0f, 20.0f);
    NSAttributedString *check = [NSAttributedString attributedStringWithAttachment:checkAttachment];
    
    self.numberLabel.attributedText = check;
}

- (void)uncheckCell {
    self.numberLabel.text = [self.number stringValue];
}

@end
