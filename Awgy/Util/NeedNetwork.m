//
//  NeedNetwork.m
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "NeedNetwork.h"

@interface NeedNetwork ()

@property (nonatomic, strong) NSMutableArray *didCallNetwork;

@end

@implementation NeedNetwork

+ (id)sharedInstance {
    static NeedNetwork *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {

        _didCallNetwork = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

- (BOOL)needNetworkForKey:(NSString *)key {
    BOOL needNetwork = YES;
    needNetwork = ![self.didCallNetwork containsObject:key];
    
    return needNetwork;
}

- (void)addDone:(NSString *)pinName {
    if (![self.didCallNetwork containsObject:pinName]) [self.didCallNetwork addObject:pinName];
}

- (void)removeDone:(NSString *)pinName {
    if ([self.didCallNetwork containsObject:pinName]) [self.didCallNetwork removeObject:pinName];
}

- (void)clear {
    [self.didCallNetwork removeAllObjects];
}


@end
