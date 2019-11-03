//
//  ActivitiesTableViewCell.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ActivitiesTableViewCell.h"
#import "Constants.h"

#import "TTTTimeIntervalFormatter.h"

CGFloat const GroupSelfieTableViewCellTextLabelFontSize = 15.0f;
CGFloat const GroupSelfieTableViewCellDateLabelFontSize = 10.0f;
CGFloat const GroupSelfieTableViewCellNameLabelFontSize = 10.0f;
CGFloat const GroupSelfieTableViewCellSeenLabelFontSize = 10.0f;

static float const left = 6.0f;
static float const right = 6.0f;

static float const spacing = 6.0f;

static float const top = 5.0f;
static float const bottom = 5.0f;

static TTTTimeIntervalFormatter *timeFormatter;

@interface ActivitiesTableViewCell ()

@property (nonatomic, strong) UILabel *dateLabel;

@end

@implementation ActivitiesTableViewCell

#pragma mark - Class

+ (CGSize)sizeThatFits:(CGSize)boundingSize forActivity:(Activity *)activity onGroupSelfie:(GroupSelfie *)groupSelfie {
    
    NSString *username = activity.fromUsername;
    if (!username) username = [PFUser currentUser].username;
    
    NSDate *date = activity.localCreatedAt;
    if (!date && activity) date = [NSDate date];
    
    float current_y = top;
    
    // Set dateLabel
    CGRect dateLabelFrame = [[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:GroupSelfieTableViewCellTextLabelFontSize]}
                                                              context:nil];
    // Set textLabel
    CGRect textLabelFrame = [[ActivitiesTableViewCell contentForActivity:activity onGroupSelfie:groupSelfie] boundingRectWithSize:CGSizeMake(boundingSize.width - dateLabelFrame.size.width - spacing - right - left, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                              context:nil];
    
    current_y += textLabelFrame.size.height + bottom;

    CGSize size = CGSizeZero;
    size.height = current_y;
    return size;
}

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];

        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont systemFontOfSize:GroupSelfieTableViewCellTextLabelFontSize];
        _dateLabel.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
        [self.contentView addSubview:_dateLabel];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        
        timeFormatter = [[TTTTimeIntervalFormatter alloc] init];

    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set dateLabel
    CGRect dateLabelFrame = [self.dateLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: self.dateLabel.font}
                                                              context:nil];
    dateLabelFrame.origin.x = self.contentView.bounds.size.width - dateLabelFrame.size.width - right;
    dateLabelFrame.origin.y = top;
    self.dateLabel.frame = CGRectIntegral(dateLabelFrame);

    
    // Set textLabel
    CGRect textLabelFrame = [self.textLabel.text boundingRectWithSize:CGSizeMake(dateLabelFrame.origin.x - spacing - left, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: self.textLabel.font}
                                                              context:nil];
    textLabelFrame.origin.x = left;
    textLabelFrame.origin.y = top;
    self.textLabel.frame = CGRectIntegral(textLabelFrame);

}

#pragma mark - Update

- (void)updateForActivity:(Activity *)activity onGroupSelfie:(GroupSelfie *)groupSelfie {
    
    self.textLabel.attributedText = [ActivitiesTableViewCell contentForActivity:activity onGroupSelfie:groupSelfie];
    
    NSDate *date = activity.localCreatedAt;
    NSString *dateFormatted;
    if (!date) {
        dateFormatted = @"now";
    } else {
        dateFormatted = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
    }
    self.dateLabel.text = dateFormatted;

    [self setNeedsLayout];
}

+ (NSAttributedString *)contentForActivity:(Activity *)activity onGroupSelfie:(GroupSelfie *)groupSelfie {
    
    PhoneBook *phoneBook = [PhoneBook sharedInstance];
    NSString *name;
    if (!activity.fromUsername || [activity.fromUsername isEqualToString:[PFUser currentUser].username]) {
        name = @"You";
    } else {
        name = [phoneBook nameShortForUsername:activity.fromUsername];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",name] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:GroupSelfieTableViewCellTextLabelFontSize], NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    NSString *content;
    UIColor *color;
    if ([activity.type isEqualToString:kActivityTypeCommentedKey]) {
        content = activity.content;
        color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
    } else if ([activity.type isEqualToString:kActivityTypeVotedKey]) {
        content = @"voted for";
        color = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f];
    } else if ([activity.type isEqualToString:kActivityTypeReVotedKey]) {
        content = @"changed vote to";
        color = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f];
    } else if ([activity.type isEqualToString:kActivityTypeCreatedKey]) {
        content = @"created";
        color = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f];
    } else if ([activity.type isEqualToString:kActivityTypeParticipatedKey]) {
        content = @"participated";
        color = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f];
    }
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:GroupSelfieTableViewCellTextLabelFontSize], NSForegroundColorAttributeName:color}]];
    
    if ([activity.type isEqualToString:kActivityTypeVotedKey] || [activity.type isEqualToString:kActivityTypeReVotedKey]) {
        NSUInteger index = [groupSelfie.groupIds indexOfObject:activity.content];
        if (index != NSNotFound && index < [groupSelfie.groupUsernames count]) {
            NSString *username = [groupSelfie.groupUsernames objectAtIndex:index];
            if ([username isEqualToString:[PFUser currentUser].username]) {
                name = @"You";
            } else {
                name = [phoneBook nameShortForUsername:username];
            }
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",name] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:GroupSelfieTableViewCellTextLabelFontSize], NSForegroundColorAttributeName:[UIColor blackColor]}]];
        }
    } else if ([activity.type isEqualToString:kActivityTypeCreatedKey]) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" #%@",activity.content] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:GroupSelfieTableViewCellTextLabelFontSize], NSForegroundColorAttributeName:[UIColor blackColor]}]];
    }
    
    return attributedString;
    
}

@end
