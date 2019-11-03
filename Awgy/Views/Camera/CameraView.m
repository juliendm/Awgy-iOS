//
//  CameraView.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "CameraView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CameraView

+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
	return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
    [(AVCaptureVideoPreviewLayer *)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [(AVCaptureVideoPreviewLayer *)[self layer] setFrame: self.bounds];
}





@end
