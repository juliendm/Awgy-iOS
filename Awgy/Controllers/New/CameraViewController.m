//
//  CameraViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "CameraViewController.h"
#import "GroupSelfieViewController.h"
#import "EditViewController.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import "GroupSelfie.h"
#import "Activity.h"
#import "Constants.h"

#import "AppDelegate.h"

#import "UIImage+animatedGIF.h"

#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import "CameraView.h"

#import <MediaPlayer/MediaPlayer.h>

#import "Filter.h"

CGFloat const CameraViewControllerDetailsFontSize = 18.0f;
CGFloat const CameraViewControllerNamesFontSize = 16.0f;
CGFloat const CameraViewControllerCountDownFontSize = 22.0f;

static float const canvas = 350.0;
#warning DO IT FOR GIF

@interface CameraViewController ()

@property (nonatomic, strong) GroupSelfie *groupSelfie;

@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) UIView *cameraFrameView;
@property (nonatomic, strong) CameraView *cameraView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *remainingSpaceView;
@property (nonatomic, strong) UIView *whiteView;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) CIDetector *detector;

@property (nonatomic) BOOL done;
@property (nonatomic, strong) NSNumber *initialBrightness;
@property (nonatomic) float brightnessValue;

@property (nonatomic) int orientation;
@property (nonatomic) UIDeviceOrientation savedDeviceOrientation;
@property (nonatomic) UIInterfaceOrientation savedInterfaceOrientation;

// Session
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;

@end

@implementation CameraViewController

- (void)dealloc {
    // Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationDidEnterBackgroundNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        //_attendees = [[NSMutableArray alloc] init];
        
        _whiteView = [[UIView alloc] init];
        _whiteView.backgroundColor = [UIColor whiteColor];
        
        _images = [[NSMutableArray alloc] init];
        
        _detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set properties if need to
    PhoneBook *phoneBook = [PhoneBook sharedInstance];
    if (![phoneBook.name count]) phoneBook.phoneNumber = [PFUser currentUser].username;
    
    _cameraFrameView = [[UIView alloc] init];
    _cameraFrameView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_cameraFrameView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.hidden = YES;
    [self.view addSubview:_imageView];
    
    #if !(TARGET_IPHONE_SIMULATOR)
    
        // Camera
    
        _cameraView = [[CameraView alloc] init];
        [_cameraFrameView addSubview:_cameraView];
    
        _whiteView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _whiteView.hidden = YES;
        [self.view addSubview:_whiteView];
    
        // AVCaptureSession
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        self.session = session;

        self.cameraView.session = session;

        [self checkDeviceAuthorizationStatus];
        
        self.sessionQueue = dispatch_queue_create("Session", DISPATCH_QUEUE_SERIAL);

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

            dispatch_async(self.sessionQueue, ^{
                NSError *error = nil;
                AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
                AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
                if ([self.session canAddInput:videoDeviceInput]) {
                    [self.session addInput:videoDeviceInput];
                    self.videoDeviceInput = videoDeviceInput;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
                        //    self.orientation = 1;
                        //    [[(AVCaptureVideoPreviewLayer *)[self.cameraView layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)self.orientation];
                        //} else {
                            [[(AVCaptureVideoPreviewLayer *)[self.cameraView layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
                        //}
                    });
                }

                AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                if ([session canAddOutput:stillImageOutput]) {
                    //[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
                    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                                                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
                    [session addOutput:stillImageOutput];
                    self.stillImageOutput = stillImageOutput;
                }
                
                AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
                if ([session canAddOutput:videoDataOutput]) {
                    [videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                                                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
                    
                    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
                    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutput", DISPATCH_QUEUE_SERIAL);
                    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
                    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

                    [session addOutput:videoDataOutput];
                    self.videoDataOutput = videoDataOutput;
                    
                }
                
            });
            
        }
        
        dispatch_async(self.sessionQueue, ^{
                [self.session startRunning];
            
        });
    
    #endif
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:AppDelegateApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:AppDelegateApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:AppDelegateApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:AppDelegateApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    CGSize size = CGSizeMake(MIN([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height), MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height));
    [self layoutSubviewsForViewFrameSize:size andOrientation:UIInterfaceOrientationPortrait];

}

- (void)viewDidAppear:(BOOL)animated {
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.currentViewController = self;
}

- (void)layoutSubviewsForViewFrameSize:(CGSize)viewFrameSize andOrientation:(UIInterfaceOrientation)orientation {
    
    if (orientation == 0) orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Camera View
    
    float camera_width = viewFrameSize.width;
    float camera_height = viewFrameSize.height;
    
    CGRect cameraFrameViewFrame = CGRectZero;
    
    cameraFrameViewFrame.size.width = camera_width;
    cameraFrameViewFrame.size.height = camera_height;
    self.cameraFrameView.frame = cameraFrameViewFrame;
    
    self.imageView.frame = self.cameraFrameView.frame;
    
    #if !(TARGET_IPHONE_SIMULATOR)
    
        self.whiteView.frame = CGRectMake(0, 0, viewFrameSize.width, viewFrameSize.height);
    
        // Camera
        
        CGRect cameraViewFrame = CGRectZero;
        cameraViewFrame.size.width = camera_width;
        cameraViewFrame.size.height = camera_height;
        self.cameraView.frame = cameraViewFrame;

        [[(AVCaptureVideoPreviewLayer *)[self.cameraView layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[[UIApplication sharedApplication] statusBarOrientation]];

    #endif
    
    
}

#pragma mark - App Cycle

- (void)applicationDidBecomeActive:(NSNotification *)note {
    
}

- (void)applicationWillResignActive:(NSNotification *)note {
    
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    #if !(TARGET_IPHONE_SIMULATOR)
        dispatch_async(self.sessionQueue, ^{
            [self.session startRunning];
        });
    #endif
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    #if !(TARGET_IPHONE_SIMULATOR)
        dispatch_async(self.sessionQueue, ^{
            [self.session stopRunning];
        });
    #endif
}

#pragma mark - Picture

- (void)setData:(NSData *)data originalData:(NSData *)originalData isGif:(BOOL)isGif {

    self.data = data;
    self.filteredData = nil;
    self.originalData = originalData;
    self.isGif = isGif;
    
    UIImage *image;
    [self.images removeAllObjects];
    if (isGif) {
        image = [UIImage animatedImageWithAnimatedGIFData:data];
        NSArray *images = image.images;
        for (UIImage *frame in images) {
            [self.images addObject:frame];
        }
    } else {
        image = [UIImage imageWithData:data];
        [self.images addObject:image];
    }
    
    self.imageView.transform = CGAffineTransformMakeScale(1, 1);
    self.imageView.image = image;
    self.imageView.hidden = NO;

}

- (void)resetImage {
    
    self.data = nil;
    self.filteredData = nil;
    self.originalData = nil;
    self.isGif = NO;
    
    [self.images removeAllObjects];
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    
}

- (void)editViewController:(EditViewController *)editViewController didSelectFilter:(NSString *)filterName {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (![filterName isEqualToString:@"None"]) {
            Filter *filter = [[Filter alloc] init];
            [filter setName:filterName];
            if (self.isGif) {
                NSMutableArray *filteredImages = [[NSMutableArray alloc] init];
                for (UIImage *image in self.images) {
                    [filteredImages addObject:[filter imageByFilteringImage:image]];
                }
                self.filteredData = [self createGif:filteredImages];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = [UIImage animatedImageWithAnimatedGIFData:self.filteredData];
                });
            } else {
                UIImage *filteredImage = [filter imageByFilteringImage:[self.images firstObject]];
                self.filteredData = UIImageJPEGRepresentation(filteredImage, 0.85f);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = filteredImage;
                });
            }
        } else {
            self.filteredData = nil;
            if (self.isGif) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = [UIImage animatedImageWithAnimatedGIFData:self.data];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = [self.images firstObject];
                });
            }
        }
        
    });

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.currentViewController == self && !self.imageView.image) {
    
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
        CFRelease(metadataDict);
        NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        self.brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
            
    }
    
}

- (void)mainTableViewController:(MainTableViewController *)mainTVC didSnapGroupSelfie:(GroupSelfie *)groupSelfie {
    
    NSLog(@"log_awgy: inside delegate selector");
    
    self.groupSelfie = groupSelfie;
    
    #if !(TARGET_IPHONE_SIMULATOR)
    
        self.savedDeviceOrientation = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.mainTableViewController.deviceOrientation;
        self.savedInterfaceOrientation = self.interfaceOrientation;
    
        NSLog(@"log_awgy: before busy");
    
        if (!self.busy) {
            
            NSLog(@"log_awgy: not busy");
            
            self.busy = YES;

            self.whiteView.alpha = 1.0f;
            self.whiteView.hidden = NO;
            
            [self resetImage];
            
            BOOL flash = self.brightnessValue < 0.0;
            self.initialBrightness = [NSNumber numberWithFloat:[UIScreen mainScreen].brightness];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).capture) {
                    if (flash) [UIScreen mainScreen].brightness = 1.0;
                    double duration = flash ? 0.2 : 0.0;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        self.done = YES;
                        [self snap:NO];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            if (!self.done) {
                                self.whiteView.alpha = 1.0f;
                                self.whiteView.hidden = NO;
                                if (flash) [UIScreen mainScreen].brightness = 1.0;
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    [self snap:NO];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                        self.whiteView.alpha = 1.0f;
                                        self.whiteView.hidden = NO;
                                        if (flash) [UIScreen mainScreen].brightness = 1.0;
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                            [self snap:NO];
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                self.whiteView.alpha = 1.0f;
                                                self.whiteView.hidden = NO;
                                                if (flash) [UIScreen mainScreen].brightness = 1.0;
                                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                    [self snap:NO];
                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                        self.whiteView.alpha = 1.0f;
                                                        self.whiteView.hidden = NO;
                                                        if (flash) [UIScreen mainScreen].brightness = 1.0;
                                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                            [self snap:YES];
                                                        });
                                                    });
                                                });
                                            });
                                        });
                                    });
                                });
                            }
                        });
                    });
                }
            });
            
        }
    
    #endif
    
}

- (void)snap:(BOOL)final {
    
    dispatch_async([self sessionQueue], ^{
        
        if (self.stillImageOutput) {
             
            [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                NSLog(@"log_awgy: %d %d %d",final ? 1 : 0, self.done ? 1 : 0, ((AppDelegate *)[[UIApplication sharedApplication] delegate]).cameraIsPressing ? 1 : 0);
                
                self.done = final || (self.done && !((AppDelegate *)[[UIApplication sharedApplication] delegate]).cameraIsPressing);
                
                float duration = self.done ? 0.3 : 0.15;
                [self reset:self.done toBrightness:self.initialBrightness withDuration:duration];
                
                if (imageDataSampleBuffer) {
                    
                    // NSData
                    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
                    UIImage *image = [self processImage:pixelBuffer toView:self.cameraView];
                    [self.images addObject:[CameraViewController resizeImage:image]];
                    
                    if (self.done) {
                        
                        self.isGif = [self.images count] > 1;
                        
                        if (self.isGif) {
                            self.data = [self createGif:self.images];
                            self.filteredData = nil;
                            self.originalData = self.data;
                        } else {
                            self.data = UIImageJPEGRepresentation([self.images firstObject], 0.85f);
                            self.filteredData = nil;
                            self.originalData = UIImageJPEGRepresentation(image, 1.0f);
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.transform = CGAffineTransformMakeScale(-1, 1);
                            
                            if (self.isGif) {
                                self.imageView.image = [UIImage animatedImageWithAnimatedGIFData:self.data];
                            } else {
                                self.imageView.image = [self.images firstObject];
                            }
                            
                            self.imageView.hidden = NO;
                            
                            EditViewController *evc = [[EditViewController alloc] init];
                            evc.delegate = self;
                            evc.groupSelfie = self.groupSelfie;
                            evc.saveOption = YES;
                            evc.thumbnailImage = [CameraViewController thumbnail:[self.images firstObject]];
                            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.mainTableViewController.navigationController pushViewController:evc animated:NO];
                        });
                    }
                    
                }
                 
            }];
             
        }
    });

}


- (NSData *)createGif:(NSArray *)images {

    NSDictionary *fileProperties = @{(__bridge id)kCGImagePropertyGIFDictionary:@{(__bridge id)kCGImagePropertyGIFLoopCount:@0,}};
    NSDictionary *frameProperties = @{(__bridge id)kCGImagePropertyGIFDictionary:@{(__bridge id)kCGImagePropertyGIFDelayTime:@0.5f,}};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, kUTTypeGIF, [images count], NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    for (UIImage *image in images) {
        CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    return data;

}

- (void)reset:(BOOL)done toBrightness:(NSNumber *)brightness withDuration:(NSTimeInterval)duration {
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.whiteView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         self.whiteView.hidden = YES;
                         if (brightness) [UIScreen mainScreen].brightness = [brightness floatValue];
                         self.busy = !done;
                     }
     ];
    
}

#pragma mark - Size

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [UIView setAnimationsEnabled:NO];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
        
        [self layoutSubviewsForViewFrameSize:self.view.frame.size andOrientation:0];
        
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [UIView setAnimationsEnabled:YES];
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

#pragma mark - Notification center


#pragma mark - Helper methods

- (UIImage *)processImage:(CVImageBufferRef)imageBuffer toView:(UIView *)view {

    // CGImageRef
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    UIImage *image;
    
    if (self.savedDeviceOrientation == UIDeviceOrientationLandscapeRight || self.savedInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationUp];
    } else if (self.savedDeviceOrientation == UIDeviceOrientationLandscapeLeft || self.savedInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationDown];
    } else {
        image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    }

    CGImageRelease(newImage);

    return image;
}

+ (UIImage *)thumbnail:(UIImage *)image {
    
    float size = MIN(image.size.width,image.size.height);
    
    CGRect rect = CGRectMake(ceilf(0.5f*(image.size.width-size)),
                             ceilf(0.5f*(image.size.height-size)),
                             ceilf(size),
                             ceilf(size));
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    UIImage *resizedImage = [CameraViewController resizeImage:croppedImage toWidth:125.0f andHeight:125.0f];
    
    return [UIImage imageWithCGImage:resizedImage.CGImage scale:resizedImage.scale orientation:UIImageOrientationUpMirrored];
    
}

+ (UIImage *)resizeImage:(UIImage *)image {
    if (image.size.height > image.size.width) {
        float new_width = MIN(canvas, image.size.width);
        return [CameraViewController resizeImage:image toWidth:new_width andHeight:ceilf(new_width/image.size.width*image.size.height)];
    } else {
        float new_height = MIN(canvas, image.size.height);
        return [CameraViewController resizeImage:image toWidth:ceilf(new_height/image.size.height*image.size.width) andHeight:new_height];
    }
}

+ (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark - Device Configuration

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark - Authorization

- (void)checkDeviceAuthorizationStatus {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                    message:NSLocalizedString(@"ACCESS_CAMERA", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                          otherButtonTitles:NSLocalizedString(@"SETTINGS", nil),nil];
                alertView.tag = 100;
                [alertView show];
            });
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 100) {
        
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        
    }
    
}

@end
