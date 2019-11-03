//
//  SingleSelfiesTableViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "SingleSelfiesTableViewController.h"
#import "SingleSelfie.h"
#import "ImageViewController.h"
#import "StreamTableViewCell.h"
#import "Constants.h"

@interface SingleSelfiesTableViewController ()

@property (nonatomic) BOOL morePeople;

@end

@implementation SingleSelfiesTableViewController

- (id)init{
    self = [super init];
    if (self) {
        self.parseClassName = kSingleSelfieClassKey;
        
        _imageViewControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setGroupSelfie:(GroupSelfie *)groupSelfie {
    _groupSelfie = groupSelfie;
    
    NSString *pinName = [SingleSelfie keyWithGroupSelfieId:groupSelfie.objectId];
    self.pinName = pinName;
    self.keyName = pinName;
    
    ImageViewController *groupSelfieImageViewController = [[ImageViewController alloc] init];
    groupSelfieImageViewController.groupSelfie = groupSelfie;
    groupSelfieImageViewController.index = 0;
    
    [_imageViewControllers removeAllObjects];
    [_imageViewControllers addObject:groupSelfieImageViewController];
    
}

#pragma mark - Loading

- (BFTask *)objectsDidLoad {
    
    NSMutableArray *tasks = [NSMutableArray array];
    for (SingleSelfie *singleSelfie in self.objects) {
        [tasks addObject:[singleSelfie loadImageSmall]];
    }
    
    return [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        
        ImageViewController *groupSelfieImageViewController = [self.imageViewControllers firstObject];
        [self.imageViewControllers removeAllObjects];
        [self.imageViewControllers addObject:groupSelfieImageViewController];
        
        if ([self.objects count] > 1) {
            
            groupSelfieImageViewController.imageView.image = self.groupSelfie.loadedImageSmall;
            groupSelfieImageViewController.imageView.file = self.groupSelfie.image;
            [groupSelfieImageViewController.imageView loadInBackground];
            
            NSInteger index = 0;
            for (SingleSelfie *singleSelfie in self.objects) {
                ImageViewController *singleSelfieImageViewController = [[ImageViewController alloc] init];
                singleSelfieImageViewController.groupSelfie = self.groupSelfie;
                dispatch_async(dispatch_get_main_queue(), ^{
                    singleSelfieImageViewController.imageView.image = singleSelfie.loadedImageSmall;
                    singleSelfieImageViewController.imageView.file = singleSelfie.image;
                });
                index++;
                singleSelfieImageViewController.index = index;
                [self.imageViewControllers addObject:singleSelfieImageViewController];
            }
        } else {
            
            SingleSelfie *singleSelfie = [self.objects firstObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                groupSelfieImageViewController.imageView.image = singleSelfie.loadedImageSmall;
                groupSelfieImageViewController.imageView.file = singleSelfie.image;
                [groupSelfieImageViewController.imageView loadInBackground];
            });
            
        }
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        [source setResult:@1];
        return source.task;
        
    }];
    
}

- (PFQuery *)queryForTable {
    PFQuery *query = [SingleSelfie query];
    [query addAscendingOrder:kCreatedAt];
    [query whereKey:kSingleSelfieToGroupSelfieIdKey equalTo:self.groupSelfie.objectId];

    return query;
}

@end
