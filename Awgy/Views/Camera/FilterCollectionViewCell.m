//
//  FilterCollectionViewCell.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@interface FilterCollectionViewCell ()

@end

@implementation FilterCollectionViewCell

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        [_imageView addSubview:_label];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect imageViewFrame = CGRectZero;
    imageViewFrame.size.width = self.frame.size.width;
    imageViewFrame.size.height = self.frame.size.height;
    self.imageView.frame = imageViewFrame;
    
    CGRect labelFrame = CGRectZero;
    labelFrame.size.width = self.frame.size.width;
    labelFrame.size.height = self.frame.size.height/3.0;
    labelFrame.origin.y = self.frame.size.height - labelFrame.size.height;
    self.label.frame = labelFrame;

}

@end
