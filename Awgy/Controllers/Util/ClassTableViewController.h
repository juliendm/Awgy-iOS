//
//  ClassTableViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "PhoneBook.h"
#import "EmptyTableView.h"

#import "MBProgressHUD.h"

#import <Bolts/BFTaskCompletionSource.h>

@protocol ClassTableViewControllerDelegate;

@interface ClassTableViewController : UITableViewController

@property (nonatomic, assign) BOOL isLocalBuildable;

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, assign) NSUInteger lastLoadCount;

@property (nonatomic, copy) NSString *parseClassName;

@property (nonatomic, copy) NSString *pinName;
@property (nonatomic, copy) NSString *keyName;

@property (nonatomic, copy) NSString *cacheSubsetKey;
@property (nonatomic, assign) BOOL cacheSubsetInverted;
@property (nonatomic, assign) BOOL cacheSubsetInPhoneBook;

@property (nonatomic, assign) NSUInteger objectsPerPage;
@property (nonatomic, assign) BOOL pullToRefreshEnabled;
@property (nonatomic, assign) BOOL paginationEnabled;
@property (nonatomic, assign) BOOL descendingOrderCreatedAt;
@property (nonatomic, assign) BOOL reversed;

@property (nonatomic, assign) BOOL alwaysNeedNetwork;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, weak) id<ClassTableViewControllerDelegate> delegate;

- (BFTask *)loadCache;
- (BFTask *)loadNetwork;

- (BFTask *)didCallNetwork;
- (BFTask *)objectsDidLoad;

- (void)objectsWillLoad;
- (void)tableViewDidReloadData;

- (PFQuery *)queryForTable;

- (void)checkIfEnoughCells;

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isNetworkAvailable;

@end

@protocol ClassTableViewControllerDelegate <NSObject>
@optional

//- (void)classTableViewController:(ClassTableViewController *)classTableVC didLoadObjects:(NSArray *)objects;
//- (void)classTableViewController:(ClassTableViewController *)classTableVC didSelectObject:(PFObject *)object;
//- (void)classTableViewController:(ClassTableViewController *)classTableVC didDeleteObject:(PFObject *)object;

@end
