//
//  MainTableViewCell.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "MainTableViewCell.h"
#import <Parse/Parse.h>

CGFloat const MainTableViewCellHashtagLabelFontSize = 22.0f;

static float const vBorder = 5.0f;
static float const hBorder = 5.0f;
static float const bckdgBorder = 5.0f;
static float const imageSize = 70.0f;

@interface MainTableViewCell ()

@property (nonatomic, strong) UIView *bckgdView;
@property (nonatomic, strong) UILabel *hashtagLabel;

@end

@implementation MainTableViewCell

#pragma mark - Class

+ (CGSize)sizeThatFits:(CGSize)boundingSize forGroupSelfie:(GroupSelfie *)groupSelfie {
    CGSize size = CGSizeZero;
    size.height = imageSize + 2.0f*vBorder + bckdgBorder;
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
        
        _hashtagLabel = [[UILabel alloc] init];
        _hashtagLabel.font = [UIFont systemFontOfSize:MainTableViewCellHashtagLabelFontSize];
        _hashtagLabel.textColor = [UIColor blackColor];
        [_bckgdView addSubview:_hashtagLabel];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.layer.cornerRadius = 5.0f;
        self.imageView.clipsToBounds = YES;
        [_bckgdView addSubview:self.imageView];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Background
    CGRect bckgdViewFrame = CGRectMake(bckdgBorder, 0.0f, self.frame.size.width - 2.0f*bckdgBorder, self.frame.size.height - bckdgBorder);
    self.bckgdView.frame = bckgdViewFrame;
    
    // Image
    CGRect imageViewFrame = CGRectZero;
    imageViewFrame.size.width = imageSize*[self.groupSelfie.imageRatio floatValue];
    imageViewFrame.size.height = imageSize;
    imageViewFrame.origin.x = bckgdViewFrame.size.width - imageViewFrame.size.width - hBorder;
    imageViewFrame.origin.y = 0.5f*(bckgdViewFrame.size.height - imageViewFrame.size.height);
    self.imageView.frame = imageViewFrame;
    
    // Hashtag
    float remainingSpace = bckgdViewFrame.size.width - imageViewFrame.size.width - 3.0f*hBorder;
    CGRect hashtagLabelFrame = [self.hashtagLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{ NSFontAttributeName : self.hashtagLabel.font }
                                                                    context:nil];
    hashtagLabelFrame.size.width = remainingSpace;
    hashtagLabelFrame.origin.x = hBorder;
    hashtagLabelFrame.origin.y = 0.5f*(bckgdViewFrame.size.height - hashtagLabelFrame.size.height);
    self.hashtagLabel.frame = hashtagLabelFrame;

}

#pragma mark - Update

- (void)updateForGroupSelfie:(GroupSelfie *)groupSelfie {
    
    _groupSelfie = groupSelfie;
    
    // Image
    PFFile *image = self.groupSelfie.image;
    if (image) {
        self.imageView.image = self.groupSelfie.loadedImageSmall;
        self.imageView.file = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView loadInBackground];
        });
    }
    
    // Hashtag
    self.hashtagLabel.text = [NSString stringWithFormat:@"#%@",self.groupSelfie.hashtag]; // [NSString stringWithFormat:@"%@",[self.groupSelfie getRelevantImprovedAt]];
    
    [self setNeedsLayout];
    
}

@end
