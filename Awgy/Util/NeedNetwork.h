//
//  NeedNetwork.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NeedNetwork : NSObject

+ (id)sharedInstance;

- (BOOL)needNetworkForKey:(NSString *)key;
- (void)addDone:(NSString *)pinName;
- (void)removeDone:(NSString *)pinName;
- (void)clear;

@end
