//
//  Relationship.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Parse/Parse.h>
#import <Bolts/BFTask.h>

@interface Relationship : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) PFUser *fromUser;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *toUsername;
@property (nonatomic, strong) NSString *toFirstName;
@property (nonatomic, strong) NSString *toLastName;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) BOOL toActive;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) NSArray *toUsernames;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSNumber *nComSelfies;
@property (nonatomic, strong) NSNumber *localNComSelfies;

- (void)clear;
- (NSNumber *)getRelevantNComSelfies;

//+ (BFTask *)relationshipWithUserId:(NSString *)userId andUsername:(NSString *)username generate:(BOOL)generate;  // not local buildable: should not pin
//- (BFTask *)saveRelationship;
//- (BFTask *)deleteRelationship;

+ (BFTask *)updateRelationships:(NSArray *)relationships;

+ (NSString *)keyWithUserId:(NSString *)userId;

@end
