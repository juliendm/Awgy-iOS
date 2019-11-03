//
//  CameraView.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface CameraView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
