//
//  EmptyTableView.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyTableView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

- (void)layoutSubviewsForFrame:(CGRect)frame;

@end
