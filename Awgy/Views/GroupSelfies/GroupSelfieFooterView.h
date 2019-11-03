//
//  GroupSelfieFooterView.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol GroupSelfieFooterViewDelegate;

@interface GroupSelfieFooterView : UIView

@property (nonatomic, strong) UITextView *commentView;
@property (nonatomic, strong) UITextView *placeHolderView;

@property (nonatomic, weak) id<GroupSelfieFooterViewDelegate> delegate;

+ (float)relevantHeightForTextView:(UITextView *)textView;

@end

@protocol GroupSelfieFooterViewDelegate <NSObject>
@optional

- (void)groupSelfieFooterView:(GroupSelfieFooterView *)footerView didTapSendButton:(UIButton *)button;

@end