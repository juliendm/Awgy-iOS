//
//  CameraViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GroupSelfie.h"
#import "PhoneBook.h"

#import "MainTableViewController.h"
#import "SetUpTableViewController.h"
#import "EditViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : UIViewController <UIAlertViewDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, MainTableViewControllerDelegate, ClassTableViewControllerDelegate, EditViewControllerDelegate>

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSData *filteredData;
@property (nonatomic, strong) NSData *originalData;

@property (nonatomic) BOOL isGif;

@property (nonatomic) BOOL busy;

- (void)setData:(NSData *)data originalData:(NSData *)originalData isGif:(BOOL)isGif;
- (void)resetImage;
- (void)reset:(BOOL)done toBrightness:(NSNumber *)brightness withDuration:(NSTimeInterval)duration;

+ (UIImage *)resizeImage:(UIImage *)image;

@end
