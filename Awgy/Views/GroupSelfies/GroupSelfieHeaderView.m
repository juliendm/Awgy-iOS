//
//  GroupSelfieHeaderView.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "GroupSelfieHeaderView.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "GroupSelfieViewController.h"

#import "StreamTableViewCell.h"

#import "Reachability.h"

CGFloat const GroupSelfieHeaderViewGuestsLabelFontSize = 13.0f;
CGFloat const GroupSelfieHeaderViewDetailsLabelFontSize = 15.0f;

@interface GroupSelfieHeaderView ()

@property (nonatomic) float imageHeight;

@end

@implementation GroupSelfieHeaderView

#pragma mark - NSObject

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // Image View
        _imageView = [[PFImageViewExtended alloc] init];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        // Picture Button
        _buttonView = [[UIView alloc] init];
        _buttonView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageAction:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapImageAction:)];
        doubleTap.numberOfTapsRequired = 2;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanImageAction:)];
        [_buttonView addGestureRecognizer:singleTap];
        [_buttonView addGestureRecognizer:doubleTap];
        [_buttonView addGestureRecognizer:pan];
        [self addSubview:_buttonView];
        
    }
    
    return self;
    
}

- (void)updateForGroupSelfie:(GroupSelfie *)groupSelfie {
    _groupSelfie = groupSelfie;
    
    self.imageHeight = [UIScreen mainScreen].bounds.size.width/[groupSelfie.imageRatio floatValue];
    

    self.imageHeight = [UIScreen mainScreen].bounds.size.width/[groupSelfie.imageRatio floatValue];
    
    if (self.imageView) {
        PFFile *image = self.groupSelfie.image;
        if (image) {
            self.imageView.image = groupSelfie.loadedImageSmall;
            self.imageView.file = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView loadInBackground];
            });
        }
    }
    
    [self layoutSubviews];

}

- (void)didTapImageAction:(UITapGestureRecognizer *)recognizer {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollPictureDown" object:nil userInfo:nil];
    
}

- (void)didDoubleTapImageAction:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        NSArray *gridIds = self.groupSelfie.gridIds;
        int n_row = [self.groupSelfie.nRow intValue];
        
        if (gridIds && n_row > 0) {
        
            int n_col = (int)[gridIds count]/n_row;

            CGPoint point = [recognizer locationInView:recognizer.view];
            
            float grid_width = [UIScreen mainScreen].bounds.size.width/(1.0*n_col);
            float grid_height = self.imageHeight/(1.0*n_row);
            
            int index;
            for (index = 0; index < [gridIds count]; index++) {
                if (point.x > index%n_col*grid_width
                    && point.x <= (index%n_col+1)*grid_width
                    && point.y > (index-index%n_col)/n_col*grid_height
                    && point.y <= ((index-index%n_col)/n_col+1)*grid_height) break;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(groupSelfieHeaderView:didTapImageWithUserId:)]) {
                [self.delegate groupSelfieHeaderView:self didTapImageWithUserId:gridIds[index]];
            }
            
        }

    }
    
}

- (void)didPanImageAction:(UIPanGestureRecognizer *)recognizer {

    static CGPoint lastTranslate;
    static CGPoint prevTranslate;

    CGPoint translate = [recognizer translationInView:recognizer.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        lastTranslate = translate;
        prevTranslate = lastTranslate;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        prevTranslate = lastTranslate;
        lastTranslate = translate;
        if ((translate.y - prevTranslate.y) < -fabs(translate.x - prevTranslate.x)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollPictureUp" object:nil userInfo:nil];
        } else if ((translate.y - prevTranslate.y) > fabs(translate.x - prevTranslate.x)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollPictureDown" object:nil userInfo:nil];
        } else if ((translate.x - prevTranslate.x) < -fabs(translate.y - prevTranslate.y)) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(groupSelfieHeaderView:didSwipeLeftView:)]) {
                [self.delegate groupSelfieHeaderView:self didSwipeLeftView:recognizer.view];
            }
        } else if ((translate.x - prevTranslate.x) > fabs(translate.y - prevTranslate.y)) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(groupSelfieHeaderView:didSwipeRightView:)]) {
                [self.delegate groupSelfieHeaderView:self didSwipeRightView:recognizer.view];
            }
        }
        
    }
}

- (NSDictionary *)numberOfVotes {
    
    NSArray *voteIds = [self.groupSelfie getRelevantVoteIds];
    NSMutableDictionary *voteIdsOrganized = [[NSMutableDictionary alloc] init];
    for (NSString *vote in voteIds) {
        NSArray *ids = [vote componentsSeparatedByString: @":"];
        [voteIdsOrganized setObject:ids[1] forKey:ids[0]];
    }
    NSMutableDictionary *numberOfVotes = [[NSMutableDictionary alloc] init];
    for (NSString *userId in [voteIdsOrganized allKeys]) {
        [numberOfVotes setObject:[NSNumber numberWithInteger:[((NSNumber *)[numberOfVotes objectForKey:userId]) intValue]+1] forKey:userId];
    }
    return numberOfVotes;
    
}

#pragma mark - GroupSelfieHeaderView

- (void)layoutSubviews {
    
    self.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, self.imageHeight);
    
    self.imageView.frame = self.frame;
    self.buttonView.frame = self.frame;
    
    [self setNeedsDisplay];

}

#pragma mark - Network

- (BOOL)isNetworkAvailable {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    BOOL available = networkStatus != NotReachable;
    
    if (!available) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return available;
}

@end


