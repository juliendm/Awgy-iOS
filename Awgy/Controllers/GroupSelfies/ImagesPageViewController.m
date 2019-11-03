//
//  ImagesPageViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ImagesPageViewController.h"

#import "ImageViewController.h"
#import "Constants.h"
#import "StreamTableViewCell.h"

@interface ImagesPageViewController ()

//@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic) NSInteger potentialIndex;
//@property (nonatomic) BOOL viewIsLoaded;

@end

@implementation ImagesPageViewController

#pragma mark - UIViewController



- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options {
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        
        //_closeButton = [[UIButton alloc] init];
        _pageControl = [[UIPageControl alloc] init];
        //_viewIsLoaded = NO;
        _potentialIndex = 0;
        
        _singleSelfiesTableViewController = [[SingleSelfiesTableViewController alloc] init];
        
    }
    return self;
}

- (void)setGroupSelfie:(GroupSelfie *)groupSelfie {
    _groupSelfie = groupSelfie;
    
    _singleSelfiesTableViewController.groupSelfie = groupSelfie;
    [_singleSelfiesTableViewController loadCache];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
//    self.viewIsLoaded = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Page Control
    [self.view addSubview: _pageControl];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [self.singleSelfiesTableViewController.imageViewControllers count];
    
    ImageViewController *ivc = [self.singleSelfiesTableViewController.imageViewControllers firstObject];
    ivc.view.frame = self.view.frame;
    [ivc resetScrollViewForFrame:self.view.frame];
    [self setViewControllers:@[ivc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self loadAllSingleSelfiesInBackground];
    
    [self layoutAdditionaViews];
    
//    for (UIView *view in self.view.subviews) {
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            UIScrollView *scrollView = (UIScrollView *)view;
//            NSLog(@"Size: %f, %f", scrollView.frame.size.width, scrollView.frame.size.height);
//        }
//    }
    
}

- (void)layoutAdditionaViews {
    if ([self.singleSelfiesTableViewController.imageViewControllers count] > 1) {
        self.pageControl.hidden = NO;
        self.pageControl.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50);
    } else {
        self.pageControl.hidden = YES;
    }
}

- (void)loadAllSingleSelfiesInBackground {
    
    for (ImageViewController *ivc in self.singleSelfiesTableViewController.imageViewControllers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ivc.imageView loadInBackground] continueWithBlock:^id(BFTask *task) {
                [ivc resetScrollViewForFrame:ivc.view.frame];
                return nil;
            }];
        });
    }

}

- (void)didTapCloseButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
        
        [self layoutAdditionaViews];

    }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {

                                 }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    if ([viewController isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)viewController;
        if (ivc.index == 0) {
            return nil;
        } else {
            ImageViewController *ivc_m1 = (ImageViewController *)self.singleSelfiesTableViewController.imageViewControllers[ivc.index-1];
            return ivc_m1;
        }
    } else {
        return nil;
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)viewController;
        if (ivc.index == [self.singleSelfiesTableViewController.imageViewControllers count]-1) {
            return nil;
        } else {
            ImageViewController *ivc_p1 = (ImageViewController *)self.singleSelfiesTableViewController.imageViewControllers[ivc.index+1];
            return ivc_p1;
        }
    } else {
        return nil;
    }
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(nonnull NSArray<UIViewController *> *)pendingViewControllers {
    if ([pendingViewControllers[0] isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)pendingViewControllers[0];
        ivc.view.frame = self.view.frame;
        [ivc resetScrollViewForFrame:ivc.view.frame];
        self.potentialIndex = ivc.index;
    } else {
        self.potentialIndex = 0;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(nonnull NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.pageControl.currentPage = self.potentialIndex;
    }
}

@end
