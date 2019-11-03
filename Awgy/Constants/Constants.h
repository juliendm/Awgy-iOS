//
//  Constants.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - NSNotification

extern NSString *const AppDelegateApplicationDidBecomeActiveNotification;
extern NSString *const AppDelegateApplicationWillResignActiveNotification;
extern NSString *const AppDelegateApplicationWillEnterForegroundNotification;
extern NSString *const AppDelegateApplicationDidEnterBackgroundNotification;

extern NSString *const PhoneBookPhoneBookHasBeenUpdatedNotification;
extern NSString *const CountryCodeCountryCodeHasBeenUpdatedNotification;

//extern NSString *const GroupSelfieGroupSelfieHasBeenUpdatedNotification;
//extern NSString *const GroupSelfiesHaveBeenRefreshedNotification;

extern NSString *const kAcceptConditionsKey;

#pragma mark - Colors

extern float const color1Red;
extern float const color1Green;
extern float const color1Blue;

extern float const color2Red;
extern float const color2Green;
extern float const color2Blue;

extern float const color3Red;
extern float const color3Green;
extern float const color3Blue;

extern float const lightGrayRed;
extern float const lightGrayGreen;
extern float const lightGrayBlue;

extern float const backgroundGrayRed;
extern float const backgroundGrayGreen;
extern float const backgroundGrayBlue;

#pragma mark - Image

extern int const canvasImage;

extern float const searchButtonHeight;

#pragma mark - Objects

// Field keys
extern NSString *const kCreatedAt;
extern NSString *const kLocalCreatedAt;
extern NSString *const kObjectIdKey;

#pragma mark - Installation Class

// Field keys
extern NSString *const kInstallationUserKey;

#pragma mark - User Class

// Class key
extern NSString *const kUserClassKey;

// Function keys
extern NSString *const kUserFunctionKey;
extern NSString *const kUserFunctionUsernameKey;
extern NSString *const kUserFunctionPasswordKey;
extern NSString *const kUserFunctionVerifCodeKey;
extern NSString *const kUserFunctionCheckUserKey;
extern NSString *const kUserFunctionAcceptConditionsKey;

// Field keys
extern NSString *const kUserNumberFriendsKey;
extern NSString *const kUserPhotoIdKey;
extern NSString *const kUserTypeKey;
extern NSString *const kUserAvailableFromKey;
extern NSString *const kUserAvailableToKey;
extern NSString *const kUserLocationKey;

extern NSString *const kTypeRegularKey;
extern NSString *const kTypeEventKey;

#pragma mark - Activity Class

// Class key
extern NSString *const kActivityClassKey;

// Field keys
extern NSString *const kActivityFromUsernameKey;
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityToGroupSelfieIdKey;
extern NSString *const kActivityContentKey;

// Type values
extern NSString *const kActivityTypeCreatedKey;
extern NSString *const kActivityTypeParticipatedKey;
extern NSString *const kActivityTypeCommentedKey;
extern NSString *const kActivityTypeVotedKey;
extern NSString *const kActivityTypeReVotedKey;

#pragma mark - Relationship Class

// Class key
extern NSString *const kRelationshipClassKey;

// Function keys
extern NSString *const kRelationshipFunctionKey;
extern NSString *const kRelationshipFunctionContactsKey;
extern NSString *const kRelationshipSponsoredFunctionKey;

// Field keys
extern NSString *const kRelationshipFromUserKey;
extern NSString *const kRelationshipToUserIdKey;
extern NSString *const kRelationshipToUsernameKey;
extern NSString *const kRelationshipActiveKey;

extern NSString *const kRelationshipTypeKey;
extern NSString *const kRelationshipTypeSingle;
extern NSString *const kRelationshipTypeGroup;

extern NSString *const kRelationshipNumberComSelfiesKey;
extern NSString *const kRelationshipLocalNumberComSelfiesKey;

#pragma mark - GroupSelfie Class

// Class key
extern NSString *const kGroupSelfieClassKey;

// Function keys
extern NSString *const kGroupSelfieFunctionAddParticipatedIdKey;
extern NSString *const kGroupSelfieFunctionAddSeenIdKey;
extern NSString *const kGroupSelfieFunctionUserKey;

extern NSString *const kGroupSelfieFunctionIdKey;

// Field keys
extern NSString *const kGroupSelfieImageKey;
extern NSString *const kGroupSelfieImageSmallKey;
extern NSString *const kGroupSelfieLocalCreatedAtKey;

extern NSString *const kGroupSelfieHashtagKey;

extern NSString *const kGroupSelfieTypeKey;
extern NSString *const kGroupSelfieTypeChallengeKey;
extern NSString *const kGroupSelfieTypePostKey;

extern NSString *const kGroupSelfieGroupIdsKey;
extern NSString *const kGroupSelfieGroupUsernamesKey;
extern NSString *const kGroupSelfieParticipatedIdsKey;
extern NSString *const kGroupSelfieSeenIdsKey;
extern NSString *const kGroupSelfieLocalSeenIdsKey;
extern NSString *const kGroupSelfieImprovedAtKey;
extern NSString *const kGroupSelfieLocalImprovedAtKey;
extern NSString *const kGroupSelfieClosedKey;

#pragma mark - SingleSelfie Class

// Class key
extern NSString *const kSingleSelfieClassKey;

// Field keys
extern NSString *const kSingleSelfieImageKey;
extern NSString *const kSingleSelfieToGroupSelfieIdKey;

#pragma mark - Verification Class

// Function keys
extern NSString *const kVerificationFunctionKey;
extern NSString *const kVerificationFunctionPhoneNumberKey;

#pragma mark - User Defaults

// Field keys
extern NSString *const kUserDefaultsDidCallNetwork;
extern NSString *const kUserDefaultsPinNames;
extern NSString *const kUserDefaultsUsernameKey;
extern NSString *const kUserDefaultsObjectIdKey;

#pragma mark - Push Notification Payload Keys

extern NSString *const kPushPayloadPayloadKey;
extern NSString *const kPushPayloadPayloadActivityKey;
//extern NSString *const kPushPayloadPayloadGroupSelfieKey;
extern NSString *const kPushPayloadPayloadRelationshipKey;

extern NSString *const kPushPayloadTypeKey;
extern NSString *const kPushPayloadTypeCreatedKey;
extern NSString *const kPushPayloadTypeParticipatedKey;
extern NSString *const kPushPayloadTypeCommentedKey;
extern NSString *const kPushPayloadTypeVotedKey;
extern NSString *const kPushPayloadTypeReVotedKey;

extern NSString *const kPushPayloadIdKey;
extern NSString *const kPushPayloadFromUsernameKey;
extern NSString *const kPushPayloadFromUserIdKey;
extern NSString *const kPushPayloadToGroupSelfieIdKey;
extern NSString *const kPushPayloadContentKey;
extern NSString *const kPushPayloadCreatedAtKey;
extern NSString *const kPushPayloadParticipatedKey;
extern NSString *const kPushPayloadVoteIdsKey;

// Double constants
double const kDelay;
