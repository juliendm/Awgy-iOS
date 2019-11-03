//
//  SingleSelfie.m
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "SingleSelfie.h"
#import "Constants.h"
#import "PinsOnFile.h"

#import <ParseUI/ParseUI.h>
#import <Bolts/BFTaskCompletionSource.h>

@interface SingleSelfie ()

@end

@implementation SingleSelfie

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kSingleSelfieClassKey;
}

@dynamic image;
@dynamic imageSmall;
@synthesize loadedImageSmall;

@dynamic toGroupSelfieId;
@dynamic relevantColor;
@dynamic imageRatio;

- (BFTask *)loadImageSmall {
    
    PFImageView *imageView = [[PFImageView alloc] init];
    imageView.file = self.imageSmall;
    return [[imageView loadInBackground] continueWithBlock:^id(BFTask *task) {
        self.loadedImageSmall = imageView.image;
        return task;
    }];
    
}

+ (NSString *)keyWithGroupSelfieId:(NSString *)groupSelfieId {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", kGroupSelfieClassKey, groupSelfieId, kSingleSelfieClassKey];
    
    PinsOnFile *pinsOnFile = [PinsOnFile sharedInstance];
    [pinsOnFile addPin:key];
    
    return key;
}

#pragma mark - Image

//+ (UIImage *)placeHolderForSingleSelfie:(SingleSelfie *)singleSelfie {
//    
//    NSString *colorHex = singleSelfie.relevantColor;
//    UIColor *color;
//    
//    if (colorHex.length == 6) {
//        color = [SingleSelfie colorFromHexString:colorHex];
//    } else {
//        color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0];
//    }
//    
//    float width = [UIScreen mainScreen].bounds.size.width;
//    float height = width/[singleSelfie.imageRatio floatValue];
//    
//    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
//    UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//    
//}
//
//+ (UIColor *)colorFromHexString:(NSString *)hexString {
//    unsigned rgbValue = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:hexString];
//    [scanner scanHexInt:&rgbValue];
//    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
//}

@end
