//
//  GroupSelfieFooterView.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "GroupSelfieFooterView.h"
#import "Constants.h"

CGFloat const FontSize = 15.0f;

#define border 5.0f

@interface GroupSelfieFooterView ()

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIView *separationView;

@end

@implementation GroupSelfieFooterView

#pragma mark - NSObject

- (id)init {
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        // Initialization code
        _placeHolderView = [[UITextView alloc] init];
        _placeHolderView.text = NSLocalizedString(@"ADD_A_MESSAGE", nil);
        _placeHolderView.font = [UIFont systemFontOfSize:FontSize];
        _placeHolderView.textColor = [UIColor lightGrayColor];
        _placeHolderView.backgroundColor = [UIColor clearColor];
        _placeHolderView.scrollEnabled = NO;
        _placeHolderView.editable = NO;
        [self addSubview:_placeHolderView];
        
        _commentView = [[UITextView alloc] init];
        _commentView.font = [UIFont systemFontOfSize:FontSize];
        _commentView.backgroundColor = [UIColor clearColor];
        _commentView.scrollEnabled = NO;
        _commentView.returnKeyType = UIReturnKeyDefault;
        //_commentView.keyboardAppearance = UIKeyboardAppearanceDark;
        //commentView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:_commentView];
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton addTarget:self action:@selector(didTapSendButton:) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton setBackgroundColor:[UIColor clearColor]];
        NSAttributedString *attributedTitle =[[NSAttributedString alloc] initWithString:NSLocalizedString(@"SEND", nil) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:FontSize], NSForegroundColorAttributeName:[UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0f]}];
        [_sendButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        [self addSubview:_sendButton];
        
        _separationView = [[UIView alloc] init];
        _separationView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_separationView];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect commentViewFrame = CGRectZero;
    commentViewFrame.origin.x = 13.0f;
    commentViewFrame.origin.y = 3.0f;
    commentViewFrame.size.height = frame.size.height - commentViewFrame.origin.y - 1.0f;
    commentViewFrame.size.width =  ceilf(frame.size.width*0.8f) - commentViewFrame.origin.x;
    
    self.placeHolderView.frame = commentViewFrame;
    self.commentView.frame = commentViewFrame;
    
    CGRect sendButtonFrame = CGRectZero;
    sendButtonFrame.origin.x = self.commentView.frame.origin.x + self.commentView.frame.size.width;
    sendButtonFrame.origin.y = frame.size.height - 45.0f;
    sendButtonFrame.size.width = frame.size.width - sendButtonFrame.origin.x;
    sendButtonFrame.size.height = 45.0f;
    
    self.sendButton.frame = sendButtonFrame;
    
    self.separationView.frame = CGRectMake(5.0f, 0.0f, frame.size.width-10.f, 0.3f);
    
}



#pragma mark - FooterView

+ (float)relevantHeightForTextView:(UITextView *)textView {
    CGRect textViewFrame = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width-10.0f,CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FontSize]}
                                                       context:nil];
    return ceilf(textViewFrame.size.height);
}

- (void)didTapSendButton:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupSelfieFooterView:didTapSendButton:)]) {
        [self.delegate groupSelfieFooterView:self didTapSendButton:button];
    }

}

@end
