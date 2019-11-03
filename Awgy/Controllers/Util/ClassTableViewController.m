//
//  ClassTableViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ClassTableViewController.h"
#import "Constants.h"
#import "NeedNetwork.h"
#import "PinsOnFile.h"

#import "GroupSelfie.h"
#import "Relationship.h"

#import "Reachability.h"

#import <Bolts/BFTask.h>

@interface ClassTableViewController ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL needLoadNextPage;
@property (nonatomic, assign) BOOL needNetwork;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic) NSString *topObjectId;

@property (nonatomic, assign) BOOL scrollViewContentSizeIsEstablished;
@property (nonatomic, assign) CGFloat previousHeight;

@end

@implementation ClassTableViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationWillEnterForegroundNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        _objects = [[NSMutableArray alloc] init];
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.descendingOrderCreatedAt = NO;
        self.reversed = NO;
        self.objectsPerPage = 25;
        
        self.isLocalBuildable = NO;
        
        self.loading = NO;
        self.needLoadNextPage = NO;
        self.needNetwork = NO;

        self.alwaysNeedNetwork = NO;
        
        self.currentPage = 0;
        self.lastLoadCount = -1;
        
        self.scrollViewContentSizeIsEstablished = YES;
        
        self.cacheSubsetKey = nil;
        self.cacheSubsetInverted = NO;
        self.cacheSubsetInPhoneBook = NO;
        
        // Notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:AppDelegateApplicationWillEnterForegroundNotification object:nil];

    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (self.pullToRefreshEnabled) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self
                           action:@selector(_refreshControlValueChanged:)
                 forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
        
        if (self.view) {
            //self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //self.hud.color = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:0.5];
            //self.hud.removeFromSuperViewOnHide = YES;
        }
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Loading

- (BFTask *)didCallNetwork {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [source setResult:@1];
    return source.task;
}

- (BFTask *)objectsDidLoad {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [source setResult:@1];
    return source.task;
}

- (void)objectsWillLoad {
    
}

- (void)tableViewDidReloadData {
    
    if (self.reversed && [_objects count]) {
        
        if (self.currentPage > 0 && self.topObjectId) {
            NSInteger index;
            for (index = [_objects count]-1; index > 0; index--) {
                PFObject *object = [_objects objectAtIndex:index];
                if ([object.objectId isEqualToString:self.topObjectId]) break;
            }
            NSInteger row = [_objects count]-1-(index+1);
            if (row >= 0) {
                @try {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                } @catch (NSException * e) {
                    
                }
            }
        } else if (!self.topObjectId) {
            @try {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_objects count]-1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            } @catch (NSException * e) {
                
            }
        }
    }

}

- (PFQuery *)queryForTable {
    return nil;
}

- (void)completeQuery:(PFQuery *)query forPage:(NSInteger)page andCache:(BOOL)cache {
    if (cache) {
        if (self.cacheSubsetKey) {
            [query whereKey:self.cacheSubsetKey equalTo:[NSNumber numberWithBool:!self.cacheSubsetInverted]];
        }
        
        if (self.cacheSubsetInPhoneBook) {
            NSArray *container = [[NSArray alloc] init];
            if (self.cacheSubsetInPhoneBook) {
                PhoneBook *phoneBook = [PhoneBook sharedInstance];
                container = [container arrayByAddingObjectsFromArray:[phoneBook.name allKeys]];
            }
            [query whereKey:kRelationshipToUsernameKey containedIn:container];
        }
        
        if (self.pinName) {
            [query fromPinWithName:self.pinName];
        } else {
            [query fromLocalDatastore];
        }
    }
    if (self.descendingOrderCreatedAt) {
        if (cache && self.isLocalBuildable && self.pinName) {
            [query addDescendingOrder:kLocalCreatedAt];
        } else {
            [query addDescendingOrder:kCreatedAt];
        }
    }
    if (cache) {
        query.limit = 1000;
    } else {
        if (self.paginationEnabled && self.objectsPerPage) {
            query.limit = self.objectsPerPage;
            query.skip = page * self.objectsPerPage;
        }
    }
}

- (BFTask *)loadCache { // Returns done after cache, even if keep going with network
    if (self.keyName && !self.alwaysNeedNetwork) {
        NeedNetwork *needNetwork = [NeedNetwork sharedInstance];
        self.needNetwork = [needNetwork needNetworkForKey:self.keyName];
    } else {
        self.needNetwork = YES;
    }
    return  [self loadObjects:0 clear:YES cache:YES];
}

- (BFTask *)loadNetwork {
    return [self loadObjects:0 clear:YES cache:NO];
}

- (BFTask *)loadObjects:(NSInteger)page clear:(BOOL)clear cache:(BOOL)cache {
    
    if (!self.loading) [self objectsWillLoad];
    self.loading = YES;
    
    if (page && self.reversed) {
        self.topObjectId = ((PFObject *)[_objects objectAtIndex:[_objects count]-1]).objectId;
    } else {
        self.topObjectId = nil;
    }
    
    PFQuery *query = [self queryForTable];
    [self completeQuery:query forPage:page andCache:cache];
    
    return [[query findObjectsInBackground] continueWithBlock:^id(BFTask *task) {
        
        if (!task.error && task.result) {
            
            NSArray *foundObjects = task.result;
            
            if (([foundObjects count] || !self.needNetwork) && cache && self.hud) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hide:YES];
                });
            }
            
            self.currentPage = page;
            self.lastLoadCount = [foundObjects count];
            
            NSLog(@"Loading %@: %d %d: %lu",self.pinName,clear,cache,(unsigned long)self.lastLoadCount);
            
            if (!cache && self.currentPage == 0 && self.pinName) {
                
                for (PFObject *object in foundObjects) {
                    if ([object isKindOfClass:[GroupSelfie class]]) {
                        GroupSelfie *groupSelfie = (GroupSelfie *)object;
                        [groupSelfie clear];
                    } else if ([object isKindOfClass:[Relationship class]]) {
                        Relationship *relationship = (Relationship *)object;
                        [relationship clear];
                    }
                }
                
                // NO NEED TO UNPIN; delete line if no problem occured for a while
                return [[PFObject unpinAllInBackground:_objects withName: self.pinName] continueWithBlock:^id(BFTask *task) {
                    return [[PFObject pinAllInBackground:foundObjects withName:self.pinName] continueWithBlock:^id(BFTask *task) {

                        PinsOnFile *pinsOnFile = [PinsOnFile sharedInstance];
                        [pinsOnFile addPin:self.pinName];
                        
                        if (self.keyName) {
                            NeedNetwork *needNetwork = [NeedNetwork sharedInstance];
                            [needNetwork addDone:self.keyName];
                        }
                        
                        return [[self didCallNetwork] continueWithBlock:^id(BFTask *task) { // a refresh is a refresh, should include this
                            return [self loadObjects:0 clear:YES cache:YES];
                        }];
                        
                    }];
                }];
                
            } else {
                
                if (clear) [_objects removeAllObjects];
                [_objects addObjectsFromArray:foundObjects];
                
                return [[self objectsDidLoad] continueWithBlock:^id(BFTask *task) {
                    self.loading = NO;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [self tableViewDidReloadData];
                        [self.refreshControl endRefreshing];
                    });
                    
                    if (self.needNetwork) {
                        self.needNetwork = NO;
                        [self loadNetwork];
                    } else if (self.paginationEnabled && self.needLoadNextPage) {
                        self.needLoadNextPage = NO;
                        [self loadObjects:(self.currentPage + 1) clear:NO cache:NO];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.hud) [self.hud hide:YES];
    //                        [self refreshEmptyView];
                        });
                    }

                    return task;
                    
                }];

            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.hud) [self.hud hide:YES];
//                [self refreshEmptyView];
            });
            
            self.lastLoadCount = -1;
            [self.refreshControl endRefreshing];
            return task;

        }
        
    }];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (indexPath.row == [self.objects count]-1) {
//
//    }
//
//}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (self.reversed) {
            return [self.objects objectAtIndex:[_objects count]-1-[self indexFromIndexPath:indexPath]];
        } else {
            return [self.objects objectAtIndex:[self indexFromIndexPath:indexPath]];
        }
    } @catch (NSException * e) {
        NSLog(@"ERROR IN CLASSTABLEVIEWCONTROLLER WHEN TRYING TO GET INDEXPATH");
        NSLog(@"Exception: %@", e);
        return nil;
    }
}

- (NSInteger)indexFromIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath object:[self objectAtIndexPath:indexPath]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    PFObject *object = [self objectAtIndexPath:indexPath];
//    
//    if (object) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(classTableViewController:didSelectObject:)]) {
//            [self.delegate classTableViewController:self didSelectObject:object];
//        }
//    }

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        PFObject *object = [self objectAtIndexPath:indexPath];
//        if (object) {
//            if (self.delegate && [self.delegate respondsToSelector:@selector(classTableViewController:didDeleteObject:)]) {
//                [self.delegate classTableViewController:self didDeleteObject:object];
//            }
//        }
//        
//    }
}

//- (void)refreshEmptyView {
//    if ([_objects count]) {
//        if (self.emptyTableView) {
//            [self.emptyTableView removeFromSuperview];
//            self.emptyTableView = nil;
//        }
//    } else {
//        if (!self.emptyTableView && self.emptyTableViewLabelTitle && self.emptyTableViewLabelMessage && self.emptyTableViewImage && self.emptyTableViewHeight) {
//            self.emptyTableView = [[EmptyTableView alloc] init];
//            self.emptyTableView.title = self.emptyTableViewLabelTitle;
//            self.emptyTableView.message = self.emptyTableViewLabelMessage;
//            self.emptyTableView.image = self.emptyTableViewImage;
//            self.emptyTableView.hideCallToAction = self.emptyTableViewHideCallToAction;
//            self.emptyTableView.delegate = self;
//            CGRect frame = CGRectZero;
//            frame.size.width = [UIScreen mainScreen].bounds.size.width;
//            frame.size.height = self.emptyTableViewHeight;
//            [self.emptyTableView layoutSubviewsForFrame:frame];
//            [self.tableView addSubview:self.emptyTableView];
//        }
//    }
//}

- (void)checkIfEnoughCells {
    if ((self.tableView.contentSize.height - self.view.frame.size.height < self.tableView.contentOffset.y + 150.0f) && (self.lastLoadCount == -1 || self.lastLoadCount >= self.objectsPerPage)) {
        [self loadNetwork];
    }
}

//- (void)emptyTableView:(EmptyTableView *)emptyTableView didTapButton:(UIButton *)button {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(classTableViewController:didTapEmptyTableViewButton:)]) {
//        [self.delegate classTableViewController:self didTapEmptyTableViewButton:button];
//    }
//}

#pragma mark - Notification center

- (void)applicationWillEnterForegroundNotification:(NSNotification *)note {
    if (self.currentPage > 0) {
        if (!self.reversed) {
            @try {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            } @catch (NSException * e) {
                
            }
        }
    }
    
    // If Misses notification (Internet went down)
    [self loadCache];
    
}

#pragma mark - Load Actions

- (void)_refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadNetwork];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.paginationEnabled) {
        if (!self.scrollViewContentSizeIsEstablished && (scrollView.contentSize.height != self.previousHeight)) self.scrollViewContentSizeIsEstablished = YES;
        self.previousHeight = scrollView.contentSize.height;
        if (!self.loading && self.scrollViewContentSizeIsEstablished) {
            
            BOOL check;
            if (self.reversed) {
                check = scrollView.contentOffset.y <= 30.0f;
            } else {
                check = scrollView.contentOffset.y >= floorf(scrollView.contentSize.height) - self.view.frame.size.height - 60.0f;
            }
            if (check) {
                
                /*MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                hud.color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:0.5];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Check";
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                hud.yOffset = ceilf(0.5f*self.view.frame.size.height);
                [hud hide:YES afterDelay:1];*/
                
                if (self.lastLoadCount == -1 || self.lastLoadCount >= self.objectsPerPage) {
                    
                    if (!self.reversed && self.navigationController.view) {
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                        hud.color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:0.8];
                        hud.mode = MBProgressHUDModeText;
                        hud.labelText = @"Loading More ...";
                        hud.margin = 10.f;
                        hud.removeFromSuperViewOnHide = YES;
                        
                        hud.yOffset = ceilf(0.5f*self.navigationController.view.frame.size.height - 2.0f*hud.margin - [UITabBarController new].tabBar.frame.size.height);
                        [hud hide:YES afterDelay:1];
                    }
                    
                    if (self.currentPage == 0) {
                        self.needLoadNextPage = YES;
                        self.needNetwork = NO;
                        self.scrollViewContentSizeIsEstablished = NO;
#warning - issue, gets called when table of length zero
                        [self loadNetwork];
                    } else {
                        self.scrollViewContentSizeIsEstablished = NO;
                        [self loadObjects:(self.currentPage + 1) clear:NO cache:NO];
                    }
                }
            }
        }
    }
    
}

#pragma mark - Network

- (BOOL)isNetworkAvailable {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    BOOL available = networkStatus != NotReachable;
    
    if (!available) {
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"It seems you are not connected to the Internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    return available;
}

@end
