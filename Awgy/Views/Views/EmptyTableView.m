//
//  EmptyTableView.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "EmptyTableView.h"
#import "Constants.h"

@interface EmptyTableView ()

@property (nonatomic, strong) UILabel *emptyTitle;
@property (nonatomic, strong) UILabel *emptyMessage;

@end

@implementation EmptyTableView

#pragma mark - NSObject

- (id)init {
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _emptyTitle = [[UILabel alloc] init];
        _emptyTitle.textColor = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f];
        _emptyTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        _emptyTitle.numberOfLines = 0;
        _emptyTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_emptyTitle];

        _emptyMessage = [[UILabel alloc] init];
        _emptyMessage.textColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0f];
        _emptyMessage.font = [UIFont systemFontOfSize:13.0f];
        _emptyMessage.numberOfLines = 0;
        _emptyMessage.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_emptyMessage];

        
    }
    return self;
}

- (void)layoutSubviewsForFrame:(CGRect)frame {
    
    self.frame = frame;
    
    float border = 5.0f;
    float borderLabel = 15.0f;
    
    // Title
    
    CGRect emptyTitleFrame = [self.title boundingRectWithSize:CGSizeMake(frame.size.width - 2.0f*borderLabel, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:self.emptyTitle.font}
                                                   context:nil];
    emptyTitleFrame.origin.x = 0.5f*(frame.size.width - emptyTitleFrame.size.width);
    emptyTitleFrame.origin.y = 50.0f;
    self.emptyTitle.frame = emptyTitleFrame;
    self.emptyTitle.text = self.title;
    
    // Message
    
    CGRect emptyMessageFrame = [self.message boundingRectWithSize:CGSizeMake(frame.size.width - 2.0f*borderLabel, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:self.emptyMessage.font}
                                                   context:nil];
    emptyMessageFrame.origin.x = 0.5f*(frame.size.width - emptyMessageFrame.size.width);
    emptyMessageFrame.origin.y = emptyTitleFrame.origin.y + emptyTitleFrame.size.height + border;
    self.emptyMessage.frame = emptyMessageFrame;
    self.emptyMessage.text = self.message;
    
}

@end
