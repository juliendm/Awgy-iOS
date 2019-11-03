//
//  StreamTableViewCell.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "StreamTableViewCell.h"
#import <Parse/Parse.h>

#import "Constants.h"

#import "MBProgressHUD.h"

@interface StreamTableViewCell ()

@property (nonatomic, strong) UIView *mainView;

@end

@implementation StreamTableViewCell

#pragma mark - Class

+ (CGSize)sizeThatFits:(CGSize)boundingSize forGroupSelfie:(GroupSelfie *)groupSelfie andFrameWidth:(float)frameWidth {
    
    float current_y = 0.0f;
    
    // Image
    
    current_y += ceilf(frameWidth/[groupSelfie.imageRatio floatValue]);
    
    // Return Size
    
    CGSize size = CGSizeZero;
    size.height = current_y;
    return size;

}

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_mainView];
        
        [_mainView addSubview:self.imageView];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect mainViewFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.mainView.frame = mainViewFrame;
    
    // Image
    
    CGRect imageViewFrame = CGRectZero;
    imageViewFrame.size.width = mainViewFrame.size.width;
    imageViewFrame.size.height = ceilf(imageViewFrame.size.width/[self.groupSelfie.imageRatio floatValue]);
    self.imageView.frame = imageViewFrame;

}

#pragma mark - Update

- (void)updateForGroupSelfie:(GroupSelfie *)groupSelfie {
    
    _groupSelfie = groupSelfie;
        
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    PFFile *image = self.groupSelfie.image;
    if (image) {
        self.imageView.image = groupSelfie.loadedImageSmall;
        self.imageView.file = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView loadInBackground];
        });
    }
    
    [self setNeedsLayout];

}

@end
