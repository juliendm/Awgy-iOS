//
//  GroupSelfie.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Parse/Parse.h>
#import <Bolts/BFTask.h>

@interface GroupSelfie : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) NSString *hashtag;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *senderUserId;

@property (nonatomic, strong) NSArray *groupUsernames;
@property (nonatomic, strong) NSArray *groupIds;
@property (nonatomic, strong) NSArray *groupRelIds;

@property (nonatomic, strong) NSArray *participatedIds;
@property (nonatomic, strong) NSArray *seenIds;
@property (nonatomic, strong) NSArray *gridIds;
@property (nonatomic, strong) NSArray *voteIds;

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSNumber *nRow;
@property (nonatomic, strong) NSNumber *nParticipants;
@property (nonatomic, strong) NSNumber *imageRatio;

@property (nonatomic, strong) NSDate *improvedAt;
@property (nonatomic, strong) NSNumber *closed;

@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) PFFile *imageSmall;
@property (nonatomic, strong) UIImage *loadedImageSmall;

@property (nonatomic, strong) NSArray *localSeenIds;
@property (nonatomic, strong) NSArray *localParticipatedIds;
@property (nonatomic, strong) NSDate *localImprovedAt;
@property (nonatomic, strong) NSArray *localVoteIds;

- (void)clear;

- (NSArray *)getRelevantSeenIds;
- (NSArray *)getRelevantParticipatedIds;
- (NSDate *)getRelevantImprovedAt;
- (NSArray *)getRelevantVoteIds;

+ (BFTask *)groupSelfieWithNotificationPayload:(NSDictionary *)notificationPayload;
+ (BFTask *)groupSelfieWithId:(NSString *)objectId loadIfNeeded:(BOOL)loadIfNeeded;

- (BFTask *)loadImageSmall;
- (BFTask *)saveGroupSelfie;

- (BFTask *)addParticipatedIdCallNetwork:(BOOL)callNetwork;
- (BFTask *)addSeenIdCallNetwork:(BOOL)callNetwork;

+ (NSString *)keyWithGroupSelfieId:(NSString *)groupSelfieId;

- (BFTask *)pinGroupSelfieWithIncrement:(BOOL)increment;
//- (BFTask *)unpinGroupSelfie;

//+ (UIImage *)placeHolderForGroupSelfie:(GroupSelfie *)groupSelfie;

@end
