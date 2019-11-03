//
//  LibraryCollectionViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "LibraryCollectionViewController.h"
#import "CameraViewController.h"
#import "EditViewController.h"

#import "LibraryCollectionViewCell.h"
#import "EmptyTableView.h"

#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface LibraryCollectionViewController ()

@property (nonatomic, strong) NSString *reuseIdentifier;

@property (nonatomic, strong) NSArray *recentPictures;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, strong) EmptyTableView *emptyTableView;

@end

@implementation LibraryCollectionViewController

- (id)init {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 2.0f;
    flowLayout.minimumInteritemSpacing = 2.0f;
    float size = 0.25*(MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)-6.0f);
    flowLayout.itemSize = CGSizeMake(size, size);
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        
        _reuseIdentifier = @"Cell";
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        _emptyTableView = [[EmptyTableView alloc] init];
        _emptyTableView.title = @"No Recent Pictures";
        _emptyTableView.message = @"You haven't taken any picture in the last few days";
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[LibraryCollectionViewCell class] forCellWithReuseIdentifier:self.reuseIdentifier];
    
    self.title = @"Recent Pictures";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapCancelButtonAction:)];

    self.navigationItem.leftBarButtonItem = cancelButton;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    if (![self.recentPictures count]) {
        [self.emptyTableView layoutSubviewsForFrame:self.collectionView.frame];
        [self.collectionView addSubview:self.emptyTableView];
    } else {
        [self.emptyTableView removeFromSuperview];
    }
    
}

- (void)didTapCancelButtonAction:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)loadRecentPictures {
    
    NSDate *compareDate = [[NSDate date] dateByAddingTimeInterval:-10*24*60*60];
    NSMutableArray *pictures = [[NSMutableArray alloc] init];
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group) {
         
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                  if (asset) {
                      NSDate *date = (NSDate *)[asset valueForProperty:ALAssetPropertyDate];
                      if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] && [date compare:compareDate] == NSOrderedDescending) {
                          //if ([[asset.defaultRepresentation.metadata objectForKey:@"{TIFF}"] objectForKey:@"Make"] || [asset.defaultRepresentation.metadata objectForKey:@"{GIF}"]) {
                              [pictures addObject:asset];
                          //}
                      }
                  }
             }];
             
         } else {
             
             self.recentPictures = [pictures sortedArrayUsingComparator:^NSComparisonResult(ALAsset *first, ALAsset *second) {
                 NSDate *date1 = [first valueForProperty:ALAssetPropertyDate];
                 NSDate *date2 = [second valueForProperty:ALAssetPropertyDate];
                 return [date2 compare:date1];
             }];
             
             [self.collectionView reloadData];
             
         }
         
     }
                               failureBlock:nil];
    
}



#pragma mark - UICollectionViewController

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.recentPictures count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LibraryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    
    ALAsset *asset = self.recentPictures[indexPath.row];
    
    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
    //image = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
    
    cell.imageView.image = image;
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ALAsset *asset = self.recentPictures[indexPath.row];
    
    ALAssetRepresentation *rep = asset.defaultRepresentation;
    
    CameraViewController *cameraViewController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController;
    
    if ([self isGif:rep]) {
    
        NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:(NSUInteger)rep.size];
        void *buffer = rawData.mutableBytes;
        [rep getBytes:buffer fromOffset:0 length:(NSUInteger)rep.size error:nil];
        NSData *data = [[NSData alloc] initWithBytes:buffer length:(NSUInteger)rep.size];
        [cameraViewController setData:data originalData:data isGif:YES];
        
    } else {
    
        CGImageRef iRef = rep.fullScreenImage;
        if (iRef) {
            UIImage *image = [UIImage imageWithCGImage:iRef];
            NSData *data = UIImageJPEGRepresentation([CameraViewController resizeImage:[LibraryCollectionViewController cropImage:image]], 0.85f);
            NSData *originalData = UIImageJPEGRepresentation(image, 1.0f);
            [cameraViewController setData:data originalData:originalData isGif:NO];
        }
        
    }
    
    EditViewController *evc = [[EditViewController alloc] init];
    evc.delegate = cameraViewController;
    evc.groupSelfie = self.groupSelfie;
    evc.saveOption = NO;
    evc.thumbnailImage = [UIImage imageWithCGImage:asset.thumbnail];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.mainTableViewController.navigationController pushViewController:evc animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)isGif:(ALAssetRepresentation *)rep {
    unsigned char signature[3];
    [rep getBytes:signature fromOffset:0 length:3 error:nil];
    return ((memcmp(signature,"GIF",3) == 0));
}

+ (UIImage *)cropImage:(UIImage *)image {
    
    float avg_x = 0.5f;
    float avg_y = 0.5f;
    
    /*CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
     NSArray *features = [self.detector featuresInImage:ciImage];
     if ([features count]) {
     float min_x = image.size.width;
     float max_x = 0.0f;
     float min_y = image.size.height;
     float max_y = 0.0f;
     for (CIFeature *feature in features) {
     if (feature.bounds.origin.x < min_x) min_x = feature.bounds.origin.x;
     if (feature.bounds.origin.x + feature.bounds.size.width > max_x) max_x = feature.bounds.origin.x + feature.bounds.size.width;
     if (feature.bounds.origin.y < min_y) min_y = feature.bounds.origin.y;
     if (feature.bounds.origin.y + feature.bounds.size.height > max_y) max_y = feature.bounds.origin.y + feature.bounds.size.height;
     }
     avg_x = 0.5f*(min_x + max_x)/image.size.width;
     avg_y = 1.0f-0.5f*(min_y + max_y)/image.size.height;
     }*/
    
    float size_width;
    float size_height;
    if (image.size.width > image.size.height) {
        size_width = MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
        size_height = MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    } else {
        size_width = MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
        size_height = MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    }
    
    float max_size_width;
    float max_size_height;
    if (image.size.width/size_width < image.size.height/size_height) {
        max_size_width = image.size.width;
        max_size_height = image.size.width/size_width*size_height;
    } else {
        max_size_width = image.size.height/size_height*size_width;
        max_size_height = image.size.height;
    }
    
    CGRect rect = CGRectMake(ceilf(MIN(MAX(0.0f,avg_x*image.size.width-0.5f*max_size_width),image.size.width-max_size_width)),
                             ceilf(MIN(MAX(0.0f,avg_y*image.size.height-0.5f*max_size_height),image.size.height-max_size_height)),
                             ceilf(max_size_width),
                             ceilf(max_size_height));
    
    return [LibraryCollectionViewController cropImage:image toRect:rect];
}

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return croppedImage;
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
