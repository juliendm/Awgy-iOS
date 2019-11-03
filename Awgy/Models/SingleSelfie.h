//
//  SingleSelfie.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Parse/Parse.h>
#import <Bolts/BFTask.h>

@interface SingleSelfie : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) PFFile *imageSmall;
@property (nonatomic, strong) UIImage *loadedImageSmall;

@property (nonatomic, strong) NSString *toGroupSelfieId;
@property (nonatomic, strong) NSString *relevantColor;
@property (nonatomic, strong) NSNumber *imageRatio;

- (BFTask *)loadImageSmall;

+ (NSString *)keyWithGroupSelfieId:(NSString *)groupSelfieId;

//+ (UIImage *)placeHolderForSingleSelfie:(SingleSelfie *)singleSelfie;

@end
