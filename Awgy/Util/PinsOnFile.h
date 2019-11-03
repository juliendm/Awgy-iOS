//
//  PinsOnFile.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>

@interface PinsOnFile : NSObject

+ (id)sharedInstance;

- (void)initiate;
- (void)addPin:(NSString *)pinName;
- (BFTask *)clear;

@end
