//
//  MainTableViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "MainTableViewController.h"

#import "LibraryCollectionViewController.h"

#import "Constants.h"

#import "MainTableViewCell.h"
#import "ActionTableViewCell.h"

#import "GroupSelfie.h"

#import "AppDelegate.h"

#import <CoreMotion/CoreMotion.h>
#import <AssetsLibrary/AssetsLibrary.h>

static float const buttonDiameter = 80.0f;
static float const margin = 10.0f;

@interface MainTableViewController ()

@property (nonatomic, strong) UIButton *numberButton;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic) NSTimeInterval lastClick;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation MainTableViewController

@dynamic delegate;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.parseClassName = kGroupSelfieClassKey;
        
        self.pinName = kGroupSelfieClassKey;
        self.keyName = kGroupSelfieClassKey;
        
        self.pullToRefreshEnabled = YES;
        
//        self.counterLabel = [[UILabel alloc] init];
//        self.counterLabel.textAlignment = NSTextAlignmentCenter;
//        self.counterLabel.layer.masksToBounds = YES;
//        self.counterLabel.font = [UIFont systemFontOfSize:13.0f];
//        self.counterLabel.textColor = [UIColor whiteColor];
//        self.counterLabel.backgroundColor = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0];
        
        _numberButton = [[UIButton alloc] init];
        _numberButton.backgroundColor = [UIColor whiteColor];
        _numberButton.layer.cornerRadius = 0.5*buttonDiameter;
        [_numberButton addTarget:self action:@selector(didTapNumberButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressAction:)];
        _longPress.minimumPressDuration = 0.1;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.counterLabel.frame = CGRectMake(ceilf(self.view.frame.size.width/5.0f*2.0f)-5.0f-20.0f, 5.0f, 20.0f, 20.0f);
//    self.counterLabel.layer.cornerRadius = ceilf(self.counterLabel.bounds.size.height/2.0f);
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    
    self.numberButton.frame = CGRectMake(self.navigationController.view.frame.size.width - buttonDiameter - margin,
                                     self.navigationController.view.frame.size.height - buttonDiameter - margin,
                                     buttonDiameter, buttonDiameter);
    [self.navigationController.view addSubview:self.numberButton];
    self.numberButton.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    // WARNING: AVOID THIS
    //[self.tableView reloadData];
    
    // AppDelegate
    
    AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    appDelegate.cameraIsPressing = NO;
    [appDelegate resetPageViewControllerDataSource];
    [appDelegate.baseViewController.pageViewController.scrollView addGestureRecognizer:self.longPress];
    
    // Orientation
    
    self.deviceOrientation = UIDeviceOrientationPortrait;
    
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (fabs(accelerometerData.acceleration.y) < fabs(accelerometerData.acceleration.x)) {
                    if (accelerometerData.acceleration.x > 0) {
                        self.deviceOrientation = UIDeviceOrientationLandscapeRight;
                    } else {
                        self.deviceOrientation = UIDeviceOrientationLandscapeLeft;
                    }
                } else {
                    self.deviceOrientation = UIDeviceOrientationPortrait;
                }
            });
        }];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController.busy = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.scrollView removeGestureRecognizer:self.longPress];
    
    if ([self.motionManager isAccelerometerAvailable]) [self.motionManager stopAccelerometerUpdates];
    
}

- (void)didTapNumberButtonAction:(id)sender {
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController setViewControllers:@[((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.streamNavigationController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

#pragma mark - Loading

- (BFTask *)objectsDidLoad {
    
    NSMutableArray *filteredGroupSelfies = [[NSMutableArray alloc] init];
    NSMutableArray *tasks = [NSMutableArray array];
    for (GroupSelfie *groupSelfie in self.objects) {
        if (![[groupSelfie getRelevantParticipatedIds] containsObject:[PFUser currentUser].objectId]){
            [filteredGroupSelfies addObject:groupSelfie];
            [tasks addObject:[groupSelfie loadImageSmall]];
        }
    }
    self.objects = filteredGroupSelfies;
    return [BFTask taskForCompletionOfAllTasks:tasks];
    
}

- (PFQuery *)queryForTable {
    PFQuery *query = [GroupSelfie query]; // Will do the job given the ACL
    [query addAscendingOrder:kCreatedAt];
    [query whereKeyExists:kGroupSelfieImageKey];
    [query whereKey:kGroupSelfieClosedKey equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:kGroupSelfieParticipatedIdsKey notEqualTo:[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsObjectIdKey]];
    
    return query;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
    
        NSString *reuseIdentifier = @"ActionCell";
        
        ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.actionLabel.text = @"New";
        
        cell.hidden = NO;
        cell.transform = CGAffineTransformMakeRotation(M_PI);
        
        return cell;
        
//    } else if (indexPath.row == 1) {
//        
//        NSString *reuseIdentifier = @"ActionCell";
//        
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        
//        cell.textLabel.text = @"PARTY";
//        cell.textLabel.textColor = [UIColor whiteColor];
//        cell.detailTextLabel.text = @"None right now - create yours on web.awgy.com";
//        cell.detailTextLabel.textColor = [UIColor whiteColor];
//        cell.backgroundColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:0.3f];
//        
//        return cell;
        
    } else {
    
        GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
        
        NSString *reuseIdentifier = @"GroupSelfieCell";
        
        MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[MainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (groupSelfie) {
            [cell updateForGroupSelfie:groupSelfie];
        }
        
        cell.hidden = NO;
        cell.transform = CGAffineTransformMakeRotation(M_PI);
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        int index = indexPath.row;
//        [arryData1 removeObjectAtIndex:index];
//        [arryData2 removeObjectAtIndex:index];
//        
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                         withRowAnimation:UITableViewRowAnimationFade];
//        
//        
//    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row > 0) {
    
        GroupSelfie *groupSelfie = (GroupSelfie *)[self objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
        if (groupSelfie) {
            return [MainTableViewCell sizeThatFits:tableView.bounds.size forGroupSelfie:groupSelfie].height;
        } else {
            return 0.0f;
        }
    
    } else {
        
        return [ActionTableViewCell sizeThatFits:tableView.bounds.size].height;
        
    }

}

- (void)handlePressWithIndexPath:(NSIndexPath *)indexPath andDate:(NSTimeInterval)date {
    
    GroupSelfie *groupSelfie;
    if (indexPath.row > 0) groupSelfie = (GroupSelfie *)[self objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
    
    if ((date - self.lastClick < 0.2) && [indexPath isEqual:self.lastIndexPath]) {
        
//        NSArray *paths = [self.tableView indexPathsForVisibleRows];
//        for (NSIndexPath *path in paths) {
//            [self.tableView cellForRowAtIndexPath:path].hidden = NO;
//        }
        
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).capture = NO;
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController reset:YES toBrightness:nil withDuration:0.5];
        
        // OPEN LIBRARY
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == ALAuthorizationStatusDenied) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                message:NSLocalizedString(@"ACCESS_ALBUMS", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                      otherButtonTitles:NSLocalizedString(@"SETTINGS", nil),nil];
            alertView.tag = 100;
            [alertView show];
        } else {
            
            LibraryCollectionViewController *libraryCollectionViewController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.libraryCollectionViewController;
            libraryCollectionViewController.groupSelfie = groupSelfie;
            CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:libraryCollectionViewController];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor blackColor];
            navigationController.navigationBar.barTintColor = [UIColor whiteColor];
            [self.navigationController presentViewController:navigationController animated:NO completion:nil];
            
        }
        
    } else {
        
        // SNAP
        
//        NSArray *paths = [self.tableView indexPathsForVisibleRows];
//        for (NSIndexPath *path in paths) {
//            if ([path compare:indexPath] != NSOrderedSame) {
//                [self.tableView cellForRowAtIndexPath:path].hidden = YES;
//            }
//        }
        
        NSLog(@"log_awgy: need snap");
        if (self.delegate && [self.delegate respondsToSelector:@selector(mainTableViewController:didSnapGroupSelfie:)]) {
            NSLog(@"log_awgy: has delegate and delegate respond to selector");
            [self.delegate mainTableViewController:self didSnapGroupSelfie:groupSelfie];
        }
        
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).capture = YES;
        
    }

}

- (void)didLongPressAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[MainTableViewController class]]) {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath) {
            NSTimeInterval now = [[[NSDate alloc] init] timeIntervalSince1970];
            if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
                [self handlePressWithIndexPath:indexPath andDate:now];
                ((AppDelegate *)[[UIApplication sharedApplication] delegate]).cameraIsPressing = YES;
            } else {
                self.lastClick = now;
                self.lastIndexPath = indexPath;
                ((AppDelegate *)[[UIApplication sharedApplication] delegate]).cameraIsPressing = NO;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"log_awgy: didSelectRowAtIndexPath");
    NSTimeInterval now = [[[NSDate alloc] init] timeIntervalSince1970];
    [self handlePressWithIndexPath:indexPath andDate:now];
    self.lastClick = now;
    self.lastIndexPath = indexPath;
}

#pragma mark - Handle groupSelfie events

- (void)manageGroupSelfie:(GroupSelfie *)groupSelfie inBackground:(BOOL)inBackground {
    
    NSUInteger index = [self.objects indexOfObject:groupSelfie];
    if (index != NSNotFound) {
        
        // Update: WARNING: INDEX+1 BECAUSE OF NEW BUTTON
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
        
        MainTableViewCell *cell = (MainTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell updateForGroupSelfie:groupSelfie];
        
        if (!inBackground) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                } @catch (NSException * e) {
                    [self.tableView reloadData];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                } @catch (NSException * e) {
                    [self.tableView reloadData];
                }
            });
        }

    } else {
        
        // Add
        
        [self.objects insertObject:groupSelfie atIndex:0];
        
        if (!inBackground) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.objects count] inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [self.tableView endUpdates];
                } @catch (NSException * e) {
                    [self.tableView reloadData];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.objects count] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                } @catch (NSException * e) {
                    [self.tableView reloadData];
                }
            });
        }
        
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    
}


@end
