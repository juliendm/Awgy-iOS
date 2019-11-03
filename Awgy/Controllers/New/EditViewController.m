//
//  EditViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "EditViewController.h"

#import "AppDelegate.h"
#import "ActionTableViewCell.h"
#import "FilterCollectionViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "Filter.h"

@interface EditViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *filteredThumbnails;
@property (nonatomic, strong) NSArray *filtersNames;

@property (nonatomic, strong) NSString *reuseIdentifier;

@end

@implementation EditViewController


- (id)init {
    self = [super init];
    if (self) {
        
        _reuseIdentifier = @"Cell";
        
        _filteredThumbnails = [[NSMutableArray alloc] init];
        //_filtersNames = @[@"None",@"Process",@"Transfer",@"Instant",@"Fade",@"Chrome",@"Noir",@"Mono",@"Tonal"];
        _filtersNames = @[@"None",@"Country",@"1977",@"Brannan",@"Gotham",@"Hefe",@"Hudson",@"Lord Kelvin",@"mayfair",@"Nashville",@"02",@"06",@"17",@"aqua",@"crossprocess",@"purple-green",@"yellow-red"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth = MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    CGFloat screenHeight = MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    CGFloat size = 0.25*(screenWidth-6.0f);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 5.0f;
    //flowLayout.minimumInteritemSpacing = 5.0f;

    flowLayout.itemSize = CGSizeMake(size, size);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 30.0, screenWidth, size) collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    
    [self.collectionView registerClass:[FilterCollectionViewCell class] forCellWithReuseIdentifier:self.reuseIdentifier];
    
    [self.view addSubview:self.collectionView];
    
    CGFloat tableHeight = 2.0f*85.0f;
    if (self.saveOption) tableHeight += 85.0f;
    CGFloat remainingHeight = MAX(0.0f, (screenHeight - tableHeight));
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, remainingHeight, screenWidth, tableHeight) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.scrollEnabled = NO;

    [self.view addSubview:self.tableView];
    
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {

    _thumbnailImage = thumbnailImage;
    
    for (NSString *filterName in self.filtersNames) {
        if (![filterName isEqualToString:@"None"]) {
            
            Filter *filter = [[Filter alloc] init];
            [filter setName:filterName];
            [self.filteredThumbnails addObject:[filter imageByFilteringImage:self.thumbnailImage]];
            
        } else {
            
            [self.filteredThumbnails addObject:self.thumbnailImage];
            
        }
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self.tableView reloadData];
    
    AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [appDelegate removePageViewControllerDataSource];
    
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.filtersNames count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = self.filteredThumbnails[indexPath.row];
    cell.label.text = self.filtersNames[indexPath.row];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewController:didSelectFilter:)]) {
        [self.delegate editViewController:self didSelectFilter:self.filtersNames[indexPath.row]];
    }
    
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.saveOption) {
        return 3;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        NSString *reuseIdentifier = @"ActionCell";
        
        ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.actionLabel.text = @"Happy :)";
        
        return cell;
        
    } else if (indexPath.row == 1) {
        
        NSString *reuseIdentifier = @"ActionCell";
        
        ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.actionLabel.text = @"Hum, nah!";
        
        return cell;
        
    } else if (indexPath.row == 2) {
        
        NSString *reuseIdentifier = @"ActionCell";
        
        ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.actionLabel.text = @"No but Save";
        
        return cell;
        
    } else {
        return nil;
    }
        
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [ActionTableViewCell sizeThatFits:tableView.bounds.size].height;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                message:NSLocalizedString(@"ACCESS_CONTACTS", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                      otherButtonTitles:NSLocalizedString(@"SETTINGS", nil),nil];
            alertView.tag = 100;
            [alertView show];
            
        } else {
    
            SetUpTableViewController *setUpTableViewController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.setUpTableViewController;
            setUpTableViewController.groupSelfie = self.groupSelfie;
            //[[setUpTableViewController loadCache] continueWithBlock:^id (BFTask *task) {
            //    dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:setUpTableViewController animated:NO];
            //    });
            //    return nil;
            //}];
            
        }
    
    } else if (indexPath.row == 1) {
        
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController resetImage];
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        
    } else if (indexPath.row == 2) {
        
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
        
            CameraViewController *cameraViewController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController;
            
            if (cameraViewController.filteredData || cameraViewController.originalData) {
                NSData *data;
                if (cameraViewController.filteredData) {
                    data = cameraViewController.filteredData;
                } else {
                    data = cameraViewController.originalData;
                }
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageDataToSavedPhotosAlbum:data metadata:@{@"{TIFF}":@{@"Make":@"Awgy"}} completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (!error) {
                        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.libraryCollectionViewController loadRecentPictures];
                    }
                }];
            }
            
            [cameraViewController resetImage];
            [self.navigationController popToRootViewControllerAnimated:NO];
            
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
