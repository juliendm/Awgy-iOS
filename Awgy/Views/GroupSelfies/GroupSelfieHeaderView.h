//
//  GroupSelfieHeaderView.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "GroupSelfie.h"
#import "PhoneBook.h"
#import "PFImageViewExtended.h"

@protocol GroupSelfieHeaderViewDelegate;

@interface GroupSelfieHeaderView : UIView

@property (nonatomic, strong) PFImageViewExtended *imageView;
@property (nonatomic, weak) GroupSelfie *groupSelfie;

@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, weak) id<GroupSelfieHeaderViewDelegate> delegate;

- (void)updateForGroupSelfie:(GroupSelfie *)groupSelfie;

@end

@protocol GroupSelfieHeaderViewDelegate <NSObject>
@optional

- (void)groupSelfieHeaderView:(GroupSelfieHeaderView *)headerView didTapImageWithUserId:(NSString *)userId;

- (void)groupSelfieHeaderView:(GroupSelfieHeaderView *)headerView didSwipeLeftView:(UIView *)view;
- (void)groupSelfieHeaderView:(GroupSelfieHeaderView *)headerView didSwipeRightView:(UIView *)view;

@end
