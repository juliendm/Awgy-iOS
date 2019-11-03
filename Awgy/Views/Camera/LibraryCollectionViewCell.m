//
//  LibraryCollectionViewCell.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "LibraryCollectionViewCell.h"

@interface LibraryCollectionViewCell ()

@end

@implementation LibraryCollectionViewCell

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
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

}

@end
