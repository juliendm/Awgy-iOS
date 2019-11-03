//
//  GroupSelfieViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "GroupSelfieViewController.h"

#import "ImagesPageViewController.h"
#import "DetailsViewController.h"

#import "AppDelegate.h"
#import "NavigationViewController.h"

#import "CustomPageViewController.h"

#import "Relationship.h"
#import "Activity.h"

#import "NeedNetwork.h"

#import "Reachability.h"

#import "Constants.h"
#import "TTTTimeIntervalFormatter.h"

@interface GroupSelfieViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *groupSelfieView;

@property (nonatomic, strong) GroupSelfieFooterView *footerView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UITextView *messageTextView;

@property (nonatomic) ABRecordRef person;
@property (nonatomic, strong) ABPersonViewController *personViewController;
@property (nonatomic, strong) ABNewPersonViewController *personNewViewController;

@property (nonatomic) float messageTextViewHeight;

@property (nonatomic) float offsetKeyboard;
@property (nonatomic) float offsetPicture;

@property (nonatomic, strong) ImagesPageViewController *imagesPageViewController;

@property (nonatomic) BOOL allImagesShowing;

@end

static TTTTimeIntervalFormatter *timeFormatter;

@implementation GroupSelfieViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scrollPictureDown" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scrollPictureUp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resignKeyboard" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationDidReceiveRemoteActivityNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        
        _activitiesTableViewController = [[ActivitiesTableViewController alloc] initWithStyle:UITableViewStylePlain];
        _activitiesTableViewController.delegate = self;
        
        _headerView = [[GroupSelfieHeaderView alloc] init];
        _headerView.delegate = self;
        
        _imagesPageViewController = [[ImagesPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey:@30}];
        
        self.hidesBottomBarWhenPushed = YES;
        
    }
    return self;
}

- (void)setGroupSelfie:(GroupSelfie *)groupSelfie {
    _groupSelfie = groupSelfie;
    
    [self.headerView updateForGroupSelfie:groupSelfie];
    [self layoutSubviews]; // IF IMAGE RATIO HAS CHANGED
    self.activitiesTableViewController.groupSelfie = groupSelfie;
    self.imagesPageViewController.groupSelfie = groupSelfie;
    
    [self updateTitleView];
    
    if (![[groupSelfie getRelevantSeenIds] containsObject:[PFUser currentUser].objectId]) {
        [groupSelfie addSeenIdCallNetwork:YES];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    // Set properties if need to
    PhoneBook *phoneBook = [PhoneBook sharedInstance];
    if (![phoneBook.name count]) phoneBook.phoneNumber = [PFUser currentUser].username;

    timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    
    [self updateTitleView];
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:nil
//                                                                     style:UIBarButtonItemStylePlain
//                                                                    target:self
//                                                                    action:@selector(didTapBackButtonAction:)];
//    [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *zoomButton = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(didTapZoomButtonAction:)];
    [zoomButton setImage:[[UIImage imageNamed:@"expand"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.navigationItem.rightBarButtonItem = zoomButton;
    
    
    
    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor colorWithRed:backgroundGrayRed green:backgroundGrayGreen blue:backgroundGrayBlue alpha:1.0f];
    [self.view addSubview:self.scrollView];
    self.scrollView.frame = self.view.frame;
    
    // Messages
    [self.scrollView addSubview:self.activitiesTableViewController.view];
    [self addChildViewController:self.activitiesTableViewController];
    [self.activitiesTableViewController didMoveToParentViewController:self];
    
    // After, for shadow
    [self.scrollView addSubview:self.headerView];
    
    // Send
    self.footerView = [[GroupSelfieFooterView alloc] init];
    self.messageTextView = self.footerView.commentView;
    self.messageTextView.delegate = self;
    self.footerView.delegate = self;
    [self.scrollView addSubview:self.footerView];
    
    self.activitiesTableViewController.headerView = self.headerView;
    self.activitiesTableViewController.footerView = self.footerView;
    
    // Layout
    self.messageTextViewHeight = 45.0f;
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneBookUpdatedNotification:) name:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollPictureDown:) name:@"scrollPictureDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollPictureUp:) name:@"scrollPictureUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignKeyboard:) name:@"resignKeyboard" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteActivityNotification:) name:AppDelegateApplicationDidReceiveRemoteActivityNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).showingGroupSelfieId = self.groupSelfie.objectId;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    // Layout
    self.offsetKeyboard = 0.0f;
    self.offsetPicture = 0.0f;
    [self layoutSubviews];
    
    self.allImagesShowing = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).keyboardIsShowing = NO;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).showingGroupSelfieId = nil;

}

- (void)updateTitleView {
    
    UIButton *hashtagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hashtagButton addTarget:self action:@selector(didTapDetailsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [hashtagButton setBackgroundColor:[UIColor clearColor]];
    
    
    NSTextAttachment *chevronAttachment = [[NSTextAttachment alloc] init];
    chevronAttachment.image = [[UIImage imageNamed:@"forward"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    chevronAttachment.bounds = CGRectMake(0.0f, -3.0f, 16.0f, 16.0f);
    NSAttributedString *chevron = [NSAttributedString attributedStringWithAttachment:chevronAttachment];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@",self.groupSelfie.hashtag] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f], NSForegroundColorAttributeName:[UIColor blackColor]}];
    [attributedString appendAttributedString:chevron];
    
    if ([self.groupSelfie.nParticipants intValue] >=2 && [self.groupSelfie.groupIds count] >= 3) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nDouble tap to vote!" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f], NSForegroundColorAttributeName:[UIColor blackColor]}]];
    } else {
        NSDate *date = self.groupSelfie.createdAt;
        NSString *string = [timeFormatter formatDate:date givenDate:[NSDate date]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",string] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f], NSForegroundColorAttributeName:[UIColor blackColor]}]];
    }
    
    [hashtagButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    hashtagButton.titleLabel.numberOfLines = 0;
    hashtagButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = hashtagButton;
    
}

//- (void)didTapBackButtonAction:(id)sender {
//
//    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.dataSource = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController;
//    [self.navigationController popViewControllerAnimated:YES];
//    
//}

- (void)didTapZoomButtonAction:(id)sender {
    [self showAllImages];
}

- (void)showAllImages {
    
    if (self.imagesPageViewController && !self.allImagesShowing) {
        self.allImagesShowing = YES;
        
# warning - MAYBE NOT LOAD CACHE EACH TIME PRESS ZOOM: ONCE WHEN ARRRIVE IN GROUPSELFIEVC, AND ALSO IF NEW IMAGES IN COLLAGE
        // Load Cache is already done when setGroupSelfie... This one is to guarantee that load is done before showing
        [[self.imagesPageViewController.singleSelfiesTableViewController loadCache] continueWithBlock:^id(BFTask *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ((AppDelegate *)[[UIApplication sharedApplication] delegate]).zoomedGroupSelfieId = self.groupSelfie.objectId;
                self.activitiesTableViewController.showingImage = YES;
                CustomPageViewController *cpcv = [[CustomPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
                [cpcv setViewControllers:@[self.imagesPageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]).mainNavigationController pushViewController:cpcv animated:NO];
            });
            return nil;
        }];
        
    }

}

- (void)didTapDetailsButtonAction:(id)sender {
    
    DetailsViewController *dvc = [[DetailsViewController alloc] init];
    dvc.groupSelfie = self.groupSelfie;
    [self.navigationController pushViewController:dvc animated:YES];
    
}

- (void)groupSelfieHeaderView:(GroupSelfieHeaderView *)headerView didSwipeLeftView:(UIView *)view {
    [self showAllImages];
}

- (void)groupSelfieHeaderView:(GroupSelfieHeaderView *)headerView didSwipeRightView:(UIView *)view {
    if ([self.parentViewController.parentViewController isKindOfClass:[NavigationViewController class]]) {
        [((NavigationViewController *)self.parentViewController.parentViewController) didTapBack];
    }
}

- (void)activitiesTableViewController:(ActivitiesTableViewController *)activitiesTableViewController didSwipeRightView:(UIView *)view {
    if ([self.parentViewController.parentViewController isKindOfClass:[NavigationViewController class]]) {
        [((NavigationViewController *)self.parentViewController.parentViewController) didTapBack];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    // Send
    CGRect footerViewFrame = CGRectZero;
    footerViewFrame.size.width = self.scrollView.frame.size.width;
    footerViewFrame.size.height = self.messageTextViewHeight;
    footerViewFrame.origin.y = self.scrollView.frame.size.height - self.messageTextViewHeight + self.offsetKeyboard - self.navigationController.navigationBar.frame.size.height;
    if (!self.offsetKeyboard) footerViewFrame.origin.y += self.offsetPicture;
    self.footerView.frame = footerViewFrame;
    
    // Messages
    CGRect tableViewFrame = CGRectZero;
    tableViewFrame.size.width = self.scrollView.frame.size.width;
    tableViewFrame.size.height = footerViewFrame.origin.y - self.headerView.frame.size.height;
    tableViewFrame.origin.y = self.headerView.frame.size.height;
    self.activitiesTableViewController.view.frame = tableViewFrame;

}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    if ([textView hasText]) {
        self.footerView.placeHolderView.hidden = YES;
        float height = [GroupSelfieFooterView relevantHeightForTextView:textView];
        if (height <= 90.0f) {
            [UIView beginAnimations:nil context:nil];
            self.messageTextViewHeight = height + 27.0f;
            [self layoutSubviews];
            [self.activitiesTableViewController scrollDown];
            [UIView commitAnimations];
            textView.scrollEnabled = NO;

        } else {
            self.messageTextViewHeight = 90.0f + 27.0f;
            [self layoutSubviews];
            textView.scrollEnabled = YES;
            NSRange range = NSMakeRange(textView.text.length - 1, 1);
            [textView scrollRangeToVisible:range];
            [self.activitiesTableViewController scrollDown];
        }

    } else {
        
        self.footerView.placeHolderView.hidden = NO;
        textView.scrollEnabled = NO;
        float height = [GroupSelfieFooterView relevantHeightForTextView:self.footerView.placeHolderView];
        [UIView beginAnimations:nil context:nil];
        self.messageTextViewHeight = height + 27.0f;
        [self layoutSubviews];
        [self.activitiesTableViewController scrollDown];
        [UIView commitAnimations];
        
    }
    
}

#pragma mark - Delegate

- (void)groupSelfieHeaderView:(GroupSelfieHeaderView *)headerView didTapImageWithUserId:(NSString *)userId {
    
    if ([self isNetworkAvailable] && [self.groupSelfie getRelevantVoteIds]) {
        
        NSArray *voteIds = [self.groupSelfie getRelevantVoteIds];
        NSMutableDictionary *voteIdsOrganized = [[NSMutableDictionary alloc] init];
        for (NSString *vote in voteIds) {
            NSArray *ids = [vote componentsSeparatedByString: @":"];
            [voteIdsOrganized setObject:ids[1] forKey:ids[0]];
        }

        if ([self.groupSelfie.nParticipants intValue] >=2 && [self.groupSelfie.groupIds count] >= 3) {

            if ([userId isEqualToString:[PFUser currentUser].objectId]) {
                
                if (self.headerView.imageView) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.headerView.imageView animated:YES];
                    hud.color = [UIColor whiteColor];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Don't vote for yourself :)";
                    hud.labelColor = [UIColor blackColor];
                    hud.margin = 10.f;
                    hud.removeFromSuperViewOnHide = YES;
                    [hud hide:YES afterDelay:1.5];
                }
                
            } else if (![[voteIdsOrganized objectForKey:[PFUser currentUser].objectId] isEqualToString:userId]) {
                
                Activity *activity = [Activity object];
                activity.content = userId;
                activity.toGroupSelfieId = self.groupSelfie.objectId;
                activity.type = [voteIdsOrganized objectForKey:[PFUser currentUser].objectId] ? kActivityTypeReVotedKey : kActivityTypeVotedKey;
                
                [self.activitiesTableViewController.objects insertObject:activity atIndex:0];
                [self.activitiesTableViewController.tableView reloadData];
                [self.activitiesTableViewController scrollDown];
                
                UIApplication * application = [UIApplication sharedApplication];
                __block UIBackgroundTaskIdentifier background_task;
                background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
                    [application endBackgroundTask: background_task];
                    background_task = UIBackgroundTaskInvalid;
                }];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [[activity saveActivityToGroupSelfie:self.groupSelfie] continueWithBlock:^id(BFTask *task) {
                        [self.activitiesTableViewController loadCache];
                        if (!task.error && task.result) {
                            [application endBackgroundTask: background_task];
                            background_task = UIBackgroundTaskInvalid;
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil) message:[task.error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
                                
                                [application endBackgroundTask: background_task];
                                background_task = UIBackgroundTaskInvalid;
                            });
                        }
                        return nil;
                    }];
                    
                });
                
            }
            
        }
        
    }

}

- (void)groupSelfieFooterView:(GroupSelfieFooterView *)footerView didTapSendButton:(UIButton *)button {
    
    if ([self.groupSelfie.groupIds count] > 1) {
    
        if ([self isNetworkAvailable]) {
        
            NSString *trimmedMessage = [[self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            if (trimmedMessage.length != 0) {

                Activity *activity = [Activity object];
                activity.content = trimmedMessage;
                activity.toGroupSelfieId = self.groupSelfie.objectId;
                activity.type = kActivityTypeCommentedKey;
                
                [self.activitiesTableViewController.objects insertObject:activity atIndex:0];
                [self.activitiesTableViewController.tableView reloadData];
                [self.activitiesTableViewController scrollDown];
                
                UIApplication * application = [UIApplication sharedApplication];
                __block UIBackgroundTaskIdentifier background_task;
                background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
                    [application endBackgroundTask: background_task];
                    background_task = UIBackgroundTaskInvalid;
                }];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                    [[activity saveActivityToGroupSelfie:self.groupSelfie] continueWithBlock:^id(BFTask *task) {
                        [self.activitiesTableViewController loadCache];
                        if (!task.error && task.result) {
                            [application endBackgroundTask: background_task];
                            background_task = UIBackgroundTaskInvalid;
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"TRY_AGAIN", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
                                
                                [application endBackgroundTask: background_task];
                                background_task = UIBackgroundTaskInvalid;
                            });
                        }
                        return nil;
                    }];
                    
                });
                
            }
            
            [self.messageTextView setText:@""];
            self.footerView.placeHolderView.hidden = NO;
            self.messageTextView.scrollEnabled = NO;
            float height = [GroupSelfieFooterView relevantHeightForTextView:self.footerView.placeHolderView];
            [UIView beginAnimations:nil context:nil];
            self.messageTextViewHeight = height + 27.0f;
            [self layoutSubviews];
            [self.activitiesTableViewController scrollDown];
            [UIView commitAnimations];
            
        }
        
    } else {
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil) message:NSLocalizedString(@"SPEAKING_ALONE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    
    }
    
}

#pragma mark - Notification center

- (void)phoneBookUpdatedNotification:(NSNotification *)note {
    self.headerView.groupSelfie = self.groupSelfie;
    [self.activitiesTableViewController.tableView reloadData];
}

- (void)scrollPictureDown:(NSNotification*)note {
    
    if (self.offsetPicture) {
        self.offsetPicture = 0.0f;
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutSubviews];
            self.scrollView.contentOffset = CGPointMake(0.0f, self.offsetPicture); // - self.navigationController.navigationBar.frame.size.height);
            [self.activitiesTableViewController scrollDown];
        }];
    }
    
}


- (void)scrollPictureUp:(NSNotification*)note {
    
    if (!self.offsetPicture) {
        self.offsetPicture = self.headerView.frame.size.height - 0.18*self.view.frame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutSubviews];
            self.scrollView.contentOffset = CGPointMake(0.0f, self.offsetPicture); // - self.navigationController.navigationBar.frame.size.height);
        }];
    }
    
}

- (void)resignKeyboard:(NSNotification*)note {
    
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).keyboardIsShowing) {
        self.activitiesTableViewController.tableView.scrollEnabled = NO;
        [self.messageTextView resignFirstResponder];
    }

}

- (void)keyboardWillShow:(NSNotification*)note {
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).keyboardIsShowing = YES;
    
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.offsetKeyboard = self.headerView.frame.size.height - kbSize.height;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutSubviews];
        self.scrollView.contentOffset = CGPointMake(0.0f, self.headerView.frame.size.height); // - self.navigationController.navigationBar.frame.size.height);
    }];
    
    [self.activitiesTableViewController scrollDown];
}

- (void)keyboardWillHide:(NSNotification*)note {
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).keyboardIsShowing = NO;
    
    self.offsetKeyboard = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutSubviews];
        self.scrollView.contentOffset = CGPointMake(0.0f, self.offsetPicture); // - self.navigationController.navigationBar.frame.size.height);
    }];

    [self.activitiesTableViewController scrollDown];
    self.activitiesTableViewController.tableView.scrollEnabled = YES;
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

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


@end
