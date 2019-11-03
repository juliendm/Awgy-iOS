//
//  Activity.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Parse/Parse.h>
#import <Bolts/BFTask.h>
#import "GroupSelfie.h"

@class GroupSelfie;

@interface Activity : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) NSString *fromUsername;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *toGroupSelfieId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *localCreatedAt;

+ (BFTask *)activityWithNotificationPayload:(NSDictionary *)notificationPayload; // local buildable: should pin
- (BFTask *)saveActivityToGroupSelfie:(GroupSelfie *)groupSelfie;

@end
