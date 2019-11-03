//
//  Relationship.m
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "Relationship.h"
#import "Constants.h"
#import "NeedNetwork.h"

#import "PhoneBook.h"

#import <Bolts/BFTaskCompletionSource.h>

@interface Relationship ()

@end

@implementation Relationship

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kRelationshipClassKey;
}

@dynamic fromUser;
@dynamic toUserId;
@dynamic toUsername;
@dynamic toFirstName;
@dynamic toLastName;
@dynamic toActive;
@dynamic active;
@dynamic type;
@dynamic toUsernames;
@dynamic name;

@dynamic nComSelfies;
@dynamic localNComSelfies;

- (void)clear {
    self.localNComSelfies = nil;
}

- (NSNumber *)getRelevantNComSelfies {
    if (self.localNComSelfies) {
        return self.localNComSelfies;
    } else {
        return self.nComSelfies;
    }
}

+ (BFTask *)relationshipWithUserId:(NSString *)userId andUsername:(NSString *)username generate:(BOOL)generate {
    
    PFQuery *query = [Relationship query];
    [query whereKey:kRelationshipToUserIdKey equalTo:userId];
    [query fromPinWithName:kRelationshipClassKey];
    return [[query getFirstObjectInBackground] continueWithBlock:^id(BFTask *task) {
        if ((task.error || !task.result) && generate) {
            Relationship *relationship = [Relationship object];
            relationship.toUserId = userId;
            relationship.toUsername = username;
            relationship.localNComSelfies = nil;
            relationship.nComSelfies = nil;
            relationship.type = kRelationshipTypeSingle;
            BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
            [source setResult:relationship];
            return source.task;
        } else {
            return task;
        }
    }];

}

+ (BFTask *)updateRelationships:(NSArray *)relationships {
    
    PhoneBook *phoneBook = [PhoneBook sharedInstance];
    
    NSArray *wantedUsernames = [phoneBook.name allKeys];
    NSMutableArray *relatedUsernames = [[NSMutableArray alloc] init];
    
    [relatedUsernames addObject:[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUsernameKey]];
    for (Relationship *relationship in relationships) [relatedUsernames addObject:relationship.toUsername];

    BOOL sameFirstName;
    BOOL sameLastName;
    for (Relationship *relationship in relationships) {
        if (![wantedUsernames containsObject:relationship.toUsername]) {
            [relationship deleteRelationship];
        } else {
            sameFirstName = [relationship.toFirstName isEqualToString:[phoneBook firstNameForUsername:relationship.toUsername]];
            sameLastName = [relationship.toLastName isEqualToString:[phoneBook lastNameForUsername:relationship.toUsername]];
            if (!sameFirstName) relationship.toFirstName = [phoneBook firstNameForUsername:relationship.toUsername];
            if (!sameLastName) relationship.toLastName = [phoneBook lastNameForUsername:relationship.toUsername];
            if (!sameFirstName || !sameLastName) [relationship saveRelationship];
        }
    }
    
    NSMutableArray *addUsernames = [[NSMutableArray alloc] init];
    NSMutableArray *addFirstNames = [[NSMutableArray alloc] init];
    NSMutableArray *addLastNames = [[NSMutableArray alloc] init];
    
    NSString *firstName;
    NSString *lastName;
    
    for (NSString *wantedUsername in wantedUsernames) {
        if (![relatedUsernames containsObject:wantedUsername]) {
            [addUsernames addObject:wantedUsername];
            firstName = [phoneBook firstNameForUsername:wantedUsername];
            [addFirstNames addObject:firstName ? firstName : (NSString *)[NSNull null]];
            lastName = [phoneBook lastNameForUsername:wantedUsername];
            [addLastNames addObject:lastName ? lastName : (NSString *)[NSNull null]];
        }
    }
    
    //for (int i = 0; i < [addUsernames count]; i++) {
    //    NSLog(@"log_awgy: %@ %@ %@",[addUsernames objectAtIndex:i],[addFirstNames objectAtIndex:i],[addLastNames objectAtIndex:i]);
    //}
    
    return [[PFCloud callFunctionInBackground:kRelationshipFunctionKey
                               withParameters:@{@"addUsernames":addUsernames,@"addFirstNames":addFirstNames,@"addLastNames":addLastNames}] continueWithBlock:^id(BFTask *task) {
        if (!task.error && task.result) {
            return [[PFObject pinAllInBackground:task.result withName:kRelationshipClassKey] continueWithBlock:^id(BFTask *task) {
                if (!task.error) {
                    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
                    [source setResult:@1];
                    return source.task;
                } else {
                    return task;
                }
            }];
        } else {
            if (!task.error) {
                BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
                // No need to load cache
                return source.task;
            } else {
                return task;
            }
        }
    }];

}

- (BFTask *)saveRelationship {
    return [[self saveInBackground] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            return [[self pinInBackgroundWithName:kRelationshipClassKey] continueWithBlock:^id(BFTask *task) {
                if (!task.error) {
                    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
                    [source setResult:@1];
                    return source.task;
                } else {
                    return task;
                }
            }];
        } else {
            return task;
        }
    }];
}

- (BFTask *)deleteRelationship {
    return [[self deleteInBackground] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            return [[self unpinInBackgroundWithName:kRelationshipClassKey] continueWithBlock:^id(BFTask *task) {
                if (!task.error) {
                    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
                    [source setResult:@1];
                    return source.task;
                } else {
                    return task;
                }
            }];
            
        } else {
            return task;
        }
    }];
}

+ (NSString *)keyWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@_%@_%@", kUserClassKey, userId, kGroupSelfieClassKey];
}

@end
