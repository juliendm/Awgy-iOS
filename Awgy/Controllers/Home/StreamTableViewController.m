//
//  StreamTableViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "StreamTableViewController.h"
#import "Constants.h"

#import "StreamTableViewCell.h"
#import "StreamTableHeaderView.h"

#import "NavigationViewController.h"

#import "Activity.h"
#import "GroupSelfieViewController.h"

#import "AppDelegate.h"

@interface StreamTableViewController ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation StreamTableViewController

@dynamic delegate;

- (void)dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:GroupSelfieGroupSelfieHasBeenUpdatedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.parseClassName = kGroupSelfieClassKey;
        
        self.pinName = kGroupSelfieClassKey;
        self.keyName = kGroupSelfieClassKey;
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        
//        self.emptyTableViewLabelTitle = NSLocalizedString(@"EMPTY_TITLE_STREAM", nil);
//        self.emptyTableViewLabelMessage = NSLocalizedString(@"EMPTY_MESSAGE_STREAM", nil);
//        self.emptyTableViewImage = [[UIImage imageNamed:@"feed_empty"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        self.emptyTableViewHeight = [UIScreen mainScreen].bounds.size.height - [UITabBarController new].tabBar.frame.size.height - 64.0f;
        
//        self.counterLabel = [[UILabel alloc] init];
//        self.counterLabel.textAlignment = NSTextAlignmentCenter;
//        self.counterLabel.layer.masksToBounds = YES;
//        self.counterLabel.font = [UIFont systemFontOfSize:13.0f];
//        self.counterLabel.textColor = [UIColor whiteColor];
//        self.counterLabel.backgroundColor = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0];
        
        // Notification
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupSelfieGroupSelfieHasBeenUpdatedNotification:) name:GroupSelfieGroupSelfieHasBeenUpdatedNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    CGRect frame = CGRectMake(0, 0, 100, 35);
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
//    imageView.backgroundColor = [UIColor clearColor];
//    imageView.image = [[UIImage imageNamed:@"awgy_styled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.navigationItem.titleView = imageView;
    
    self.tableView.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:nil
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:self
//                                                                  action:@selector(didTapBackButtonAction:)];
//    [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    self.navigationItem.leftBarButtonItem = backButton;
//    
//    UIBarButtonItem *ellipsisButton = [[UIBarButtonItem alloc] initWithTitle:nil
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:self
//                                                                  action:@selector(didTapEllipsisButtonAction:)];
//    [ellipsisButton setImage:[[UIImage imageNamed:@"ellipsis"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    self.navigationItem.rightBarButtonItem = ellipsisButton;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    self.isShowing = YES;
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.dataSource = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController;
    
    //[((AppDelegate *)[[UIApplication sharedApplication] delegate]) resetBaseNavigationController];
    
    // NEEDED TO UPDATE SEEN/UNSEEN AND DATES
    [self.tableView reloadData];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(tableViewReloadData) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.currentViewController = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.isShowing = NO;
    
    [self.timer invalidate];
}

- (void)tableViewReloadData {
    [self.tableView reloadData];
}

//- (void)didTapBackButtonAction:(id)sender {
//    
//    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController setViewControllers:@[((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
//
//}

//- (void)didTapEllipsisButtonAction:(id)sender {
//
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
//    actionSheet.delegate = self;
//    [actionSheet addButtonWithTitle:NSLocalizedString(@"PRIVACY_POLICY", nil)];
//    [actionSheet addButtonWithTitle:NSLocalizedString(@"TERMS_OF_USE", nil)];
//    [actionSheet addButtonWithTitle:@"Contact Us"];
//    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
//    
//    actionSheet.cancelButtonIndex = 3;
//    
//    [actionSheet showInView:self.view];
//    
//}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//    if (buttonIndex == actionSheet.cancelButtonIndex) {
//        
//    } else if (buttonIndex == 0) {
//        NSURL *url = [NSURL URLWithString:@"https://awgy.com/page-privacy-policy.html"];
//        [[UIApplication sharedApplication] openURL:url];
//    } else if (buttonIndex == 1) {
//        NSURL *url = [NSURL URLWithString:@"https://awgy.com/page-terms-of-use.html"];
//        [[UIApplication sharedApplication] openURL:url];
//    } else if (buttonIndex == 2) {
//        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
//        [composer setMailComposeDelegate:self];
//        if([MFMailComposeViewController canSendMail]) {
//            [composer setToRecipients:@[@"info@awgy.com"]];
//            [composer setSubject:[NSString stringWithFormat:@"Hello!"]];
//            [self presentViewController:composer animated:YES completion:nil];
//        }
//    }
//    
//}

//- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}


#pragma mark - Loading

- (BFTask *)objectsDidLoad {
    
//    [self refreshCounterLabel];

#warning todo
    
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GroupSelfieViewController class]]) {
        GroupSelfieViewController *gsvc = (GroupSelfieViewController *)[self.navigationController.viewControllers lastObject];
        for (GroupSelfie *groupSelfie in self.objects) {
            if ([gsvc.groupSelfie.objectId isEqualToString:groupSelfie.objectId]) {
                if (![[groupSelfie getRelevantSeenIds] containsObject:[PFUser currentUser].objectId]) {
                    [groupSelfie addSeenIdCallNetwork:YES];
                }
                break;
            }
        }
    }
    
    [self.objects sortUsingComparator:^NSComparisonResult(GroupSelfie *groupSelfie1, GroupSelfie *groupSelfie2) {
        NSDate *date1 = [groupSelfie1 getRelevantImprovedAt];
        NSDate *date2 = [groupSelfie2 getRelevantImprovedAt];
        return [date2 compare:date1];
    }];
        
    NSMutableArray *tasks = [NSMutableArray array];
    for (GroupSelfie *groupSelfie in self.objects) {
        [tasks addObject:[groupSelfie loadImageSmall]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
    
}

//- (void)refreshCounterLabel {
//
//    int count = 0;
//    for (GroupSelfie *groupSelfie in self.objects) {
//        if (![[groupSelfie getRelevantSeenIds] containsObject:[PFUser currentUser].objectId]) {
//            count++;
//        }
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.counterLabel removeFromSuperview];
//        if (count) {
//            self.counterLabel.text = [NSString stringWithFormat:@"%d",count];
//            [self.tabBarController.tabBar addSubview:self.counterLabel];
//        }
//    });
//
//}

- (PFQuery *)queryForTable {
    
    PFQuery *query = [GroupSelfie query]; // Will do the job given the ACL
    [query whereKeyExists:kGroupSelfieImageKey];
    [query orderByDescending:kGroupSelfieImprovedAtKey];
    
    return query;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.objects count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)indexFromIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:indexPath];
    
    
    StreamTableHeaderView *view = [[StreamTableHeaderView alloc] init];
    [view updateForGroupSelfie:groupSelfie];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:indexPath];
    
    return [StreamTableHeaderView sizeThatFits:tableView.bounds.size forGroupSelfie:groupSelfie].height;

}

- (StreamTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(GroupSelfie *)groupSelfie {
    
    NSString *reuseIdentifier = @"Cell";
    
    StreamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[StreamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (groupSelfie) {
        [cell updateForGroupSelfie:groupSelfie];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:indexPath];
    if (groupSelfie) {
        return [StreamTableViewCell sizeThatFits:tableView.bounds.size forGroupSelfie:groupSelfie andFrameWidth:self.view.frame.size.width].height;
    } else {
        return 0.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:indexPath];
    
    if (groupSelfie) {
        
        GroupSelfieViewController *gsvc = [[GroupSelfieViewController alloc] init];
        gsvc.groupSelfie = groupSelfie;
        [[gsvc.activitiesTableViewController loadCache] continueWithBlock:^id(BFTask *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.dataSource = nil;
                //[self.navigationController pushViewController:gsvc animated:YES];
                
                NavigationViewController *navigationViewController = [[NavigationViewController alloc] initWithRootViewController:gsvc];
                [self.navigationController pushViewController:navigationViewController animated:YES];
                
            });
            return nil;
        }];
        
    }

}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (![self.objects count]) {
//        return UITableViewCellEditingStyleNone;
//    } else {
//        GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:indexPath];
//        if (groupSelfie) {
//            return UITableViewCellEditingStyleDelete;
//        } else {
//            return UITableViewCellEditingStyleNone;
//        }
//    }
//    
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NSLocalizedString(@"DELETE", nil);
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete && [self isNetworkAvailable]) {
//        
//        GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:indexPath];
//        
//        if (groupSelfie) {
//        
//            [self.objects removeObjectAtIndex:indexPath.row];
//            [self didDeleteObject:groupSelfie];
//            
//            [CATransaction begin];
//            [CATransaction setCompletionBlock:^{
//                [self checkIfEnoughCells];
////                [self refreshEmptyView];
////                [self refreshCounterLabel];
//            }];
//            [self.tableView beginUpdates];
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//            [self.tableView endUpdates];
//            [CATransaction commit];
//            
//            [[groupSelfie deleteGroupSelfie] continueWithBlock:^id(BFTask *task) {
//                if (task.error) {
//                    
//                    [self.objects insertObject:groupSelfie atIndex:indexPath.row];
//                    [self didAddObject:groupSelfie];
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [CATransaction begin];
//                        [CATransaction setCompletionBlock:^{
////                            [self refreshEmptyView];
////                            [self refreshCounterLabel];
//                        }];
//                        [self.tableView beginUpdates];
//                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                        [self.tableView endUpdates];
//                        [CATransaction commit];
//                        
//                        NSString *message = [task.error.userInfo objectForKey:@"error"];
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
//                                                                            message:message
//                                                                           delegate:self
//                                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                                                  otherButtonTitles:nil];
//                        [alertView show];
//                    });
//                }
//                
//                return nil;
//            }];
//            
//        }
//        
//    }
//}

- (void)didAddObject:(GroupSelfie *)groupSelfie {}
- (void)didDeleteObject:(GroupSelfie *)groupSelfie {}

#pragma mark - Handle groupSelfie events

- (void)manageGroupSelfie:(GroupSelfie *)groupSelfie inBackground:(BOOL)inBackground {
    
    NSUInteger index = [self.objects indexOfObject:groupSelfie];
    if (index != NSNotFound) {
        
        [self.objects removeObjectAtIndex:index];
        [self.objects insertObject:groupSelfie atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    @try {
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    } @catch (NSException * e) {
                        [self.tableView reloadData];
                    }
                }];
                [self.tableView beginUpdates];
                [self.tableView moveSection:index toSection:0];
                [self.tableView endUpdates];
                [CATransaction commit];
            } @catch (NSException * e) {
                [self.tableView reloadData];
            }
        });
        
    } else {
        
        [self.objects insertObject:groupSelfie atIndex:0];
        BOOL needRemove = ([self.objects count] > self.objectsPerPage);
        if (needRemove) {
            [self.objects removeObjectAtIndex:[self.objects count]-1];
            self.lastLoadCount = -1;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.tableView beginUpdates];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
                if (needRemove) [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[self.objects count]-1] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            } @catch (NSException * e) {
                [self.tableView reloadData];
            }
        });
        
        
//        // Load Image
//        PFImageViewExtended *imageView = [[PFImageViewExtended alloc] init];
//        imageView.file = groupSelfie.imageSmall;
//        [imageView loadInBackground];
        
        
        
    }
    
//        [self refreshCounterLabel];
    

}

- (void)groupSelfieGroupSelfieHasBeenUpdatedNotification:(NSNotification *)note {
    [self loadCache];
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
