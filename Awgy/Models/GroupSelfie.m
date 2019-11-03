//
//  GroupSelfie.m
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "GroupSelfie.h"
#import "Relationship.h"
#import "Constants.h"
#import "PinsOnFile.h"

#import "CameraViewController.h"
#import "GroupSelfieViewController.h"
#import "BaseViewController.h"
#import "StreamTableViewCell.h"

#import <ParseUI/ParseUI.h>
#import <Bolts/BFTaskCompletionSource.h>

@interface GroupSelfie ()

@end

@implementation GroupSelfie

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kGroupSelfieClassKey;
}

@dynamic hashtag;
@dynamic type;
@dynamic senderUserId;
@dynamic groupUsernames;
@dynamic groupIds;
@dynamic groupRelIds;
@dynamic participatedIds;
@dynamic seenIds;
@dynamic gridIds;
@dynamic voteIds;
@dynamic colors;
@dynamic nRow;
@dynamic nParticipants;
@dynamic imageRatio;
@dynamic improvedAt;
@dynamic closed;

@dynamic image;
@dynamic imageSmall;
@synthesize loadedImageSmall;

@dynamic localSeenIds;
@dynamic localParticipatedIds;
@dynamic localImprovedAt;
@dynamic localVoteIds;

- (void)clear {
    self.localSeenIds = nil;
    self.localParticipatedIds = nil;
    self.localImprovedAt = nil;
    self.localVoteIds = nil;
}



- (NSArray *)getRelevantSeenIds {
    if (self.localSeenIds) {
        return self.localSeenIds;
    } else {
        return self.seenIds;
    }
}

- (NSArray *)getRelevantParticipatedIds {
    if (self.localParticipatedIds) {
        return self.localParticipatedIds;
    } else {
        return self.participatedIds;
    }
}

- (NSDate *)getRelevantImprovedAt {
    if (self.localImprovedAt) {;
        return self.localImprovedAt;
    } else {
        return self.improvedAt;
    }
}

- (NSArray *)getRelevantVoteIds {
    if (self.localVoteIds) {
        return self.localVoteIds;
    } else {
        return self.voteIds;
    }
}


+ (BFTask *)groupSelfieWithNotificationPayload:(NSDictionary *)notificationPayload {
    
    PFQuery *query = [GroupSelfie query];
    [query fromPinWithName:kGroupSelfieClassKey];
    return [[query getObjectInBackgroundWithId:[notificationPayload objectForKey:kPushPayloadToGroupSelfieIdKey]] continueWithBlock:^id(BFTask *task) {
        if (!task.error && task.result) {
            
            // Already in memory
            
            GroupSelfie *groupSelfie = (GroupSelfie *)task.result;
            
            NSString *type = [notificationPayload objectForKey:kPushPayloadTypeKey];
            if ([type isEqualToString:kPushPayloadTypeCommentedKey] || [type isEqualToString:kPushPayloadTypeVotedKey] || [type isEqualToString:kPushPayloadTypeReVotedKey]) {
                
                // Refresh and pin without increment
                groupSelfie.localSeenIds = [[NSArray alloc] init]; // Empty Array
                groupSelfie.localImprovedAt = [NSDate dateWithTimeIntervalSince1970:[[notificationPayload objectForKey:kPushPayloadCreatedAtKey] doubleValue]/1000.0];
                if ([notificationPayload objectForKey:kPushPayloadVoteIdsKey]) groupSelfie.localVoteIds = [notificationPayload objectForKey:kPushPayloadVoteIdsKey];
                
                return [[groupSelfie pinGroupSelfieWithIncrement:NO] continueWithBlock:^id(BFTask *task) {
                    if (!task.error && task.result) {
                        return [[groupSelfie loadImageSmall] continueWithBlock:^id(BFTask *loadTask) {
                            BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
                            [source setResult:groupSelfie];
                            return source.task;
                        }];
                    } else {
                        return task;
                    }
                }];
                
            } else {
                
                // Load and pin without increment
            
                [groupSelfie clear];
                
                PFQuery *query = [GroupSelfie query];
                return [[query getObjectInBackgroundWithId:[notificationPayload objectForKey:kPushPayloadToGroupSelfieIdKey]] continueWithBlock:^id(BFTask *task) {
                    if (!task.error && task.result) {
                        return [[task.result pinGroupSelfieWithIncrement:NO] continueWithBlock:^id(BFTask *pinTask) {
                            if (!pinTask.error && pinTask.result) {
                                return [[(GroupSelfie *)task.result loadImageSmall] continueWithBlock:^id(BFTask *loadTask) {
                                    return task;
                                }];
                            } else {
                                return pinTask;
                            }
                        }];
                    } else {
                        return task;
                    }
                }];

            }
            
        } else {
            
            // First time seen : Load and pin with increment
            
            PFQuery *query = [GroupSelfie query];
            return [[query getObjectInBackgroundWithId:[notificationPayload objectForKey:kPushPayloadToGroupSelfieIdKey]] continueWithBlock:^id(BFTask *task) {
                if (!task.error && task.result) {
                    return [[task.result pinGroupSelfieWithIncrement:YES] continueWithBlock:^id(BFTask *pinTask) {
                        if (!pinTask.error && pinTask.result) {
                            return [[(GroupSelfie *)task.result loadImageSmall] continueWithBlock:^id(BFTask *loadTask) {
                                return task;
                            }];
                        } else {
                            return pinTask;
                        }
                    }];
                } else {
                    return task;
                }
            }];
            
        }
    }];
    
}


+ (BFTask *)groupSelfieWithId:(NSString *)objectId loadIfNeeded:(BOOL)loadIfNeeded {

    PFQuery *query = [GroupSelfie query];
    [query fromPinWithName:kGroupSelfieClassKey];
    return [[query getObjectInBackgroundWithId:objectId] continueWithBlock:^id(BFTask *task) {
        if ((task.error || !task.result) && loadIfNeeded) {
            PFQuery *query = [GroupSelfie query];
            return [[query getObjectInBackgroundWithId:objectId] continueWithBlock:^id(BFTask *task) {
                if (!task.error && task.result) {
                    return [[task.result pinGroupSelfieWithIncrement:YES] continueWithBlock:^id(BFTask *pinTask) {
                        if (!pinTask.error && pinTask.result) {
                            return [[(GroupSelfie *)task.result loadImageSmall] continueWithBlock:^id(BFTask *loadTask) {
                                return task;
                            }];
                        } else {
                            return pinTask;
                        }
                    }];
                } else {
                    return task;
                }
            }];
        } else {
            return task;
        }
    }];

}

- (BFTask *)loadImageSmall {
    
    PFImageView *imageView = [[PFImageView alloc] init];
    imageView.file = self.imageSmall;
    return [[imageView loadInBackground] continueWithBlock:^id(BFTask *task) {
        self.loadedImageSmall = imageView.image;
        return task;
    }];
    
}

- (BFTask *)saveGroupSelfie {
    
    return [[self saveInBackground] continueWithBlock:^id(BFTask *task) {
        if (!task.error && task.result) {
            return [self pinGroupSelfieWithIncrement:YES];
        } else {
            return task;
        }
    }];
    
}


- (BFTask *)addParticipatedIdCallNetwork:(BOOL)callNetwork {
    
    NSMutableArray *participatedIds;
    if ([self getRelevantParticipatedIds]) {
        participatedIds = [[self getRelevantParticipatedIds] mutableCopy];
    } else {
        participatedIds = [[NSMutableArray alloc] init];
    }
    if (![participatedIds containsObject:[PFUser currentUser].objectId]) [participatedIds addObject:[PFUser currentUser].objectId];
    self.localParticipatedIds = participatedIds;
    
    NSLog(@"log_awgy: has now partipicated");
    
    return [[self pinGroupSelfieWithIncrement:NO] continueWithBlock:^id(BFTask *task) {
        NSLog(@"log_awgy: has now partipicated and pinned");
        if (callNetwork) {
            [PFCloud callFunctionInBackground:kGroupSelfieFunctionAddParticipatedIdKey
                               withParameters:@{kObjectIdKey:self.objectId}];
        }
        return task;
    }];
    
}

- (BFTask *)addSeenIdCallNetwork:(BOOL)callNetwork {
    
    NSMutableArray *seenIds;
    if ([self getRelevantSeenIds]) {
        seenIds = [[self getRelevantSeenIds] mutableCopy];
    } else {
        seenIds = [[NSMutableArray alloc] init];
    }
    if (![seenIds containsObject:[PFUser currentUser].objectId]) [seenIds addObject:[PFUser currentUser].objectId];
    self.localSeenIds = seenIds;
    
    return [[self pinGroupSelfieWithIncrement:NO] continueWithBlock:^id(BFTask *task) {
        if (callNetwork) {
            [PFCloud callFunctionInBackground:kGroupSelfieFunctionAddSeenIdKey
                               withParameters:@{kObjectIdKey:self.objectId}];
        }
        return task;
    }];
    
}

#pragma mark - Pin

- (BFTask *)pinGroupSelfieWithIncrement:(BOOL)increment {
    
    NSMutableArray *tasks = [NSMutableArray array];
    
    [tasks addObject:[self pinInBackgroundWithName:kGroupSelfieClassKey]];
    
    if (increment) {
        
        // increase related relationships counters
        PFQuery *query = [Relationship query];
        [query whereKey:kRelationshipNumberComSelfiesKey greaterThanOrEqualTo:@0];
        query.limit = 1000;
        [query fromPinWithName:kRelationshipClassKey];
        [tasks addObject:[[query findObjectsInBackground] continueWithBlock:^id(BFTask *task) {
            if (!task.error && task.result) {
                NSMutableArray *tasks_in = [NSMutableArray array];
                for (Relationship *relationship in task.result) {
                    if ([self.groupUsernames containsObject:relationship.toUsername]) {
                        int number = [[relationship getRelevantNComSelfies] intValue];
                        number++;
                        relationship.localNComSelfies = [NSNumber numberWithInt:number];
                        [tasks_in addObject:[relationship pinInBackgroundWithName:kRelationshipClassKey]];
                    }
                }
                return [BFTask taskForCompletionOfAllTasks:tasks_in];
            } else {
                // Succeed even if can't find a relationship to increment
                BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
                [source setResult:@1];
                return source.task;
            }
        }]];
    
    }
    
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

- (BFTask *)unpinGroupSelfie {
    
    NSMutableArray *tasks = [NSMutableArray array];
    
    [tasks addObject:[self unpinInBackgroundWithName:kGroupSelfieClassKey]];
    [tasks addObject:[PFObject unpinAllObjectsInBackgroundWithName:[GroupSelfie keyWithGroupSelfieId:self.objectId]]];
    
    // decrease related relationships counters
    PFQuery *relationship_query = [Relationship query];
    [relationship_query whereKey:kRelationshipNumberComSelfiesKey greaterThanOrEqualTo:@0];
    relationship_query.limit = 1000;
    [relationship_query fromPinWithName:kRelationshipClassKey];
    [tasks addObject:[[relationship_query findObjectsInBackground] continueWithBlock:^id(BFTask *task) {
        if (!task.error && task.result) {
            NSMutableArray *tasks_in = [NSMutableArray array];
            for (Relationship *relationship in task.result) {
                if ([self.groupUsernames containsObject:relationship.toUsername]) {
                    int number = [[relationship getRelevantNComSelfies] intValue];
                    number--;
                    if (number<0) number = 0;
                    relationship.localNComSelfies = [NSNumber numberWithInt:number];
                    [tasks_in addObject:[relationship pinInBackgroundWithName:kRelationshipClassKey]];
                }
            }
            return [BFTask taskForCompletionOfAllTasks:tasks_in];
        } else {
            // Succeed even if can't find a relationship to decrement
            BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
            [source setResult:@1];
            return source.task;
        }
    }]];
    
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

+ (NSString *)keyWithGroupSelfieId:(NSString *)groupSelfieId {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", kGroupSelfieClassKey, groupSelfieId, kActivityClassKey];
    
    PinsOnFile *pinsOnFile = [PinsOnFile sharedInstance];
    [pinsOnFile addPin:key];
    
    return key;
}

#pragma mark - Image

//+ (UIImage *)placeHolderForGroupSelfie:(GroupSelfie *)groupSelfie {
//    
//    NSArray *colors = groupSelfie.colors;
//    int n_row = [groupSelfie.nRow intValue];
//    
//    if (colors && n_row > 0) {
//
//        int n_col = (int)[colors count]/n_row;
//        
//        float canvas = floorf([UIScreen mainScreen].bounds.size.width/n_col);
//        
//        float width = n_col*canvas;
//        float height = n_row*canvas;
//        
//        CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
//        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
//        CGContextFillRect(context, rect);
//        
//        int current_x;
//        int current_y;
//        NSString *colorHex;
//        UIColor *color;
//        
//        for (int index = 0; index < [colors count]; index++) {
//            
//            current_x = index%n_col * canvas;
//            current_y = (index-index%n_col)/n_col * canvas;
//            colorHex = colors[index];
//            
//            if (![colorHex isEqual:[NSNull null]] && colorHex.length == 6) {
//                color = [GroupSelfie colorFromHexString:colorHex];
//            } else {
//                color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0];
//            }
//            
//            [color setFill];
//            
//            CGContextMoveToPoint(context, current_x, current_y);
//            CGContextAddLineToPoint(context, current_x + canvas, current_y);
//            CGContextAddLineToPoint(context, current_x + canvas, current_y + canvas);
//            CGContextAddLineToPoint(context, current_x, current_y + canvas);
//            CGContextClosePath(context);
//            CGContextFillPath(context);
//            
//        }
//        
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        return image;
//        
//    } else {
//        
//        float width = [UIScreen mainScreen].bounds.size.width;
//        float height = width/[groupSelfie.imageRatio floatValue];
//        
//        CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
//        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0] CGColor]);
//        CGContextFillRect(context, rect);
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        return image;
//        
//    }
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
