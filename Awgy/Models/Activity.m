//
//  Activity.m
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "Activity.h"
#import "Constants.h"

#import <Bolts/BFTaskCompletionSource.h>

@interface Activity ()

@end

@implementation Activity

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kActivityClassKey;
}

@dynamic fromUsername;
@dynamic type;
@dynamic toGroupSelfieId;
@dynamic content;
@dynamic localCreatedAt;

+ (BFTask *)activityWithNotificationPayload:(NSDictionary *)notificationPayload {
    
    // no need to fetch local datastore since only one push per activity
    
    Activity *activity = [super object];
    activity.objectId = [notificationPayload objectForKey:kPushPayloadIdKey];
    activity.type = [notificationPayload objectForKey:kPushPayloadTypeKey];
    activity.fromUsername = [notificationPayload objectForKey:kPushPayloadFromUsernameKey];
    activity.toGroupSelfieId = [notificationPayload objectForKey:kPushPayloadToGroupSelfieIdKey];
    activity.content = [notificationPayload objectForKey:kPushPayloadContentKey];
    activity.localCreatedAt = [NSDate dateWithTimeIntervalSince1970:[[notificationPayload objectForKey:kPushPayloadCreatedAtKey] doubleValue]/1000.0];
    
    return [[activity pinInBackgroundWithName:[GroupSelfie keyWithGroupSelfieId:activity.toGroupSelfieId]] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
            [source setResult:@1];
            return source.task;
        } else {
            return task;
        }
    }];
    
}

- (BFTask *)saveActivityToGroupSelfie:(GroupSelfie *)groupSelfie {
    
    groupSelfie.localImprovedAt = [NSDate date];
    
    return [[self saveInBackground] continueWithBlock:^id(BFTask *task) {
        if (!task.error && task.result) {
            
            groupSelfie.localImprovedAt = self.createdAt;
            
            if ([self.type isEqualToString:kActivityTypeVotedKey] || [self.type isEqualToString:kActivityTypeReVotedKey]) {
                NSMutableArray *voteIds;
                if ([groupSelfie getRelevantVoteIds]) {
                    voteIds = [[groupSelfie getRelevantVoteIds] mutableCopy];
                } else {
                    voteIds = [[NSMutableArray alloc] init];
                }
                [voteIds addObject:[NSString stringWithFormat:@"%@:%@",[PFUser currentUser].objectId,self.content]];
                groupSelfie.localVoteIds = voteIds;
            }
            
            [groupSelfie pinGroupSelfieWithIncrement:false];
            return [self pinInBackgroundWithName:[GroupSelfie keyWithGroupSelfieId:self.toGroupSelfieId]];
        } else {
            return task;
        }
    }];

}

@end
