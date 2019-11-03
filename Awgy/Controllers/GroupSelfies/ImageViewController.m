//
//  ImageViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ImageViewController.h"
#import "GroupSelfieViewController.h"
#import "Constants.h"

#import "AppDelegate.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic) BOOL actionSheetIsShowing;

@end

@implementation ImageViewController

#pragma mark - View Controller Lifecycle

- (void)dealloc {
    // NSLog([NSString stringWithFormat:@"Dealloc %@",self.imageView.file.url]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateApplicationWillResignActiveNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        
        _scrollView = [[UIScrollView alloc] init];
        _imageView = [[PFImageViewExtended alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.actionSheetIsShowing = NO;
    
    // ScrollView
    _scrollView.delegate = self;
    _scrollView.contentSize = _imageView.image ? _imageView.image.size : CGSizeZero;
    
    _scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_scrollView];
    
    // Image
    [_imageView sizeToFit];
    [_scrollView addSubview:_imageView];
    //[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    
    // Recognizer
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(doubleTapFrom:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [_scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    //longPress.delegate = self;
    longPress.minimumPressDuration=0.5;
    [_scrollView addGestureRecognizer:longPress];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:AppDelegateApplicationWillResignActiveNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self resetScrollViewForFrame:self.view.frame];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).zoomedGroupSelfieId = nil;
    
}

- (void)applicationWillResignActive:(NSNotification *)note {
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

#pragma mark - double tap

- (void)doubleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    float newScale = self.scrollView.zoomScale * 2.0;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = self.imageView.frame.size.height / scale;
    zoomRect.size.width  = self.imageView.frame.size.width  / scale;
    
    center = [self.imageView convertPoint:center fromView:self.scrollView];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

#pragma mark - Properties

- (void)resetScrollViewForFrame:(CGRect)frame {
        
    self.scrollView.frame = frame;
    
    double zoom1 = floor(frame.size.width/self.imageView.image.size.width*1000)/1000;
    double zoom2 = floor(frame.size.height/self.imageView.image.size.height*1000)/1000;
    
    if (zoom1 < zoom2) {
        self.scrollView.minimumZoomScale = zoom1;
        self.scrollView.zoomScale = zoom1;
        
    } else {
        self.scrollView.minimumZoomScale = zoom2;
        self.scrollView.zoomScale = zoom2;
    }
    self.scrollView.maximumZoomScale = MAX(zoom1,zoom2)*3.0;
    
    //NSLog(@"Zoom: %f, %f",self.scrollView.zoomScale,self.scrollView.minimumZoomScale);
    
    CGFloat offsetX = MAX((frame.size.width - self.scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((frame.size.height - self.scrollView.contentSize.height) * 0.5, 0.0);
    
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,
                                 self.scrollView.contentSize.height * 0.5 + offsetY);
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Notification

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale && !self.actionSheetIsShowing) {
        self.actionSheetIsShowing = YES;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SAVE", nil)];
        actionSheet.cancelButtonIndex = 2;
        [actionSheet addButtonWithTitle:@"Email"];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
        
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    self.actionSheetIsShowing = NO;
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
    } else if (buttonIndex == 0) {
        
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
            
            if (self.imageView.data) {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageDataToSavedPhotosAlbum:self.imageView.data metadata:nil completionBlock:nil];
            } else {
                UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
            }
            
        }
        
    } else if (buttonIndex == 1) {
        
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        [composer setMailComposeDelegate:self];
        if([MFMailComposeViewController canSendMail]) {
            [composer setSubject:[NSString stringWithFormat:@"Awgy: #%@",self.groupSelfie.hashtag]];
            
            if (self.imageView.data && [[self.groupSelfie.image.name pathExtension] isEqualToString:@"gif"]) {
                NSData *data = self.imageView.data;
                [composer addAttachmentData:data  mimeType:@"image/gif" fileName:@"image.gif"];
            } else {
                NSData *data = UIImageJPEGRepresentation(self.imageView.image,1);
                [composer addAttachmentData:data  mimeType:@"image/jpeg" fileName:@"image.jpg"];
            }
            [self presentViewController:composer animated:YES completion:nil];
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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - view transition

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [UIView setAnimationsEnabled:YES];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self resetScrollViewForFrame:self.view.frame];

    }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                 [UIView setAnimationsEnabled:YES];
                                 }];

    [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
}

@end
