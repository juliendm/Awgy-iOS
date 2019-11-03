//
//  StreamTableHeaderView.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "StreamTableHeaderView.h"
#import <Parse/Parse.h>

#import "TTTTimeIntervalFormatter.h"
#import "Constants.h"

CGFloat const StreamTableViewCellHashtagLabelFontSize = 19.0f;
CGFloat const StreamTableViewCellInfoLabelFontSize = 16.0f;

static float const margin = 6.0f;
static float const sideMargin = 5.0f;
static float const labelMargin = 3.0f;

@interface StreamTableHeaderView ()

@property (nonatomic, strong) UILabel *hashtagLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@end

static TTTTimeIntervalFormatter *timeFormatter;

@implementation StreamTableHeaderView

#pragma mark - Class

+ (CGSize)sizeThatFits:(CGSize)boundingSize forGroupSelfie:(GroupSelfie *)groupSelfie {
    
    float current_y = margin;
    
    // Hashtag
    
    CGRect hashtagLabelFrame = [[NSString stringWithFormat:@"#%@",groupSelfie.hashtag] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:StreamTableViewCellHashtagLabelFontSize] }
                                                                    context:nil];
    
    current_y += hashtagLabelFrame.size.height;
    
    current_y += margin;
    
    // Return Size
    
    CGSize size = CGSizeZero;
    size.height = current_y;
    return size;

}

#pragma mark - Init

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _hashtagLabel = [[UILabel alloc] init];
        _hashtagLabel.font = [UIFont systemFontOfSize:StreamTableViewCellHashtagLabelFontSize];
        _hashtagLabel.textColor = [UIColor blackColor];
        [self addSubview:_hashtagLabel];

        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:StreamTableViewCellInfoLabelFontSize];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.layer.cornerRadius = 5.0f;
        _infoLabel.clipsToBounds = YES;
        [self addSubview:_infoLabel];
        
        timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //CGRect mainViewFrame = CGRectMake(0.0f, topMargin, self.frame.size.width, self.frame.size.height-topMargin);
    //self.frame = mainViewFrame;
    
    // Sizing
    
    CGRect hashtagLabelFrame = [self.hashtagLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{ NSFontAttributeName : self.hashtagLabel.font }
                                                                    context:nil];
    hashtagLabelFrame.origin.x = sideMargin;
    hashtagLabelFrame.origin.y = margin;
    
    // Info
    
    CGRect infoLabelFrame = [self.infoLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{ NSFontAttributeName : self.hashtagLabel.font }
                                                              context:nil];
    infoLabelFrame.size.width += labelMargin;
    infoLabelFrame.size.height += labelMargin;
    infoLabelFrame.origin.x = self.frame.size.width - infoLabelFrame.size.width - sideMargin;
    infoLabelFrame.origin.y = hashtagLabelFrame.origin.y + 0.5f*(hashtagLabelFrame.size.height - infoLabelFrame.size.height);
    self.infoLabel.frame = infoLabelFrame;
    
    // Hashtag
    
    hashtagLabelFrame.size.width = self.frame.size.width - infoLabelFrame.size.width - 2.0f*sideMargin;
    self.hashtagLabel.frame = hashtagLabelFrame;

}

#pragma mark - Update

- (void)updateForGroupSelfie:(GroupSelfie *)groupSelfie {
    
    _groupSelfie = groupSelfie;
    
    // Hashtag
    
    self.hashtagLabel.text = [NSString stringWithFormat:@"#%@",self.groupSelfie.hashtag];
    
    // Info
    
    self.infoLabel.attributedText = nil;
    NSDate *improvedDate = [self.groupSelfie getRelevantImprovedAt];
    NSString *dateFormatted;
    if (improvedDate) {
        dateFormatted = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:improvedDate];
    } else {
        dateFormatted = @"now";
    }
    self.infoLabel.text = dateFormatted;
    
    if ([[groupSelfie getRelevantSeenIds] containsObject:[PFUser currentUser].objectId]) {
        self.infoLabel.backgroundColor = [UIColor whiteColor];
        self.infoLabel.textColor = [UIColor blackColor];
    } else {
        self.infoLabel.backgroundColor = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0];
        self.infoLabel.textColor = [UIColor whiteColor];
    }
    
    [self setNeedsLayout];

}

@end
