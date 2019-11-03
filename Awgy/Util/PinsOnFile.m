//
//  PinsOnFile.m
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "PinsOnFile.h"
#import <Parse/Parse.h>
#import "Constants.h"

#import <Bolts/BFTaskCompletionSource.h>

@interface PinsOnFile ()

@property (nonatomic, strong) NSMutableArray *pinNames;

@end

@implementation PinsOnFile

+ (id)sharedInstance {
    static PinsOnFile *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _pinNames = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsPinNames] mutableCopy];
        if (!_pinNames) _pinNames = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)initiate {
    NSArray *pinNames = @[kGroupSelfieClassKey,kRelationshipClassKey,kUserClassKey];
    [self.pinNames removeAllObjects];
    [self.pinNames addObjectsFromArray:pinNames];
    [[NSUserDefaults standardUserDefaults] setObject:pinNames forKey:kUserDefaultsPinNames];
}

- (void)addPin:(NSString *)pinName {
    
    if (![self.pinNames containsObject:pinName]) {
        if ([self.pinNames count] >= 150) {
            NSString *pinName = [self.pinNames firstObject];
            [PFObject unpinAllObjectsInBackgroundWithName:pinName];
            [self.pinNames removeObjectAtIndex:0];
        }
        [self.pinNames addObject:pinName];
        [[NSUserDefaults standardUserDefaults] setObject:self.pinNames forKey:kUserDefaultsPinNames];

    }
    
}

- (BFTask *)clear {
    
    NSMutableArray *tasks = [NSMutableArray array];
    
    [tasks addObject:[PFObject unpinAllObjectsInBackground]];
    for (NSString *pinName in self.pinNames) {
        [tasks addObject:[PFObject unpinAllObjectsInBackgroundWithName:pinName]];
    }
    [self.pinNames removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kUserDefaultsPinNames];
    
    return [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
            [source setResult:@1];
            return source.task;
        } else {
            return task;
        }
    }];
    
}


@end
