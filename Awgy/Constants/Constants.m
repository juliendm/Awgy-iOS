//
//  Constants.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "Constants.h"

#pragma mark - NSNotification

NSString *const AppDelegateApplicationDidBecomeActiveNotification             = @"appDelegate.applicationDidBecomeActiveNotification";
NSString *const AppDelegateApplicationWillResignActiveNotification            = @"appDelegate.applicationWillResignActiveNotification";
NSString *const AppDelegateApplicationWillEnterForegroundNotification         = @"appDelegate.applicationWillEnterForegroundNotification";
NSString *const AppDelegateApplicationDidEnterBackgroundNotification          = @"appDelegate.applicationDidEnterBackgroundNotification";

NSString *const PhoneBookPhoneBookHasBeenUpdatedNotification           = @"phoneBook.phoneBookHasBeenUpdatedNotification";
NSString *const CountryCodeCountryCodeHasBeenUpdatedNotification       = @"countryCode.countryCodeHasBeenUpdatedNotification";

NSString *const GroupSelfieGroupSelfieHasBeenUpdatedNotification       = @"groupSelfie.groupSelfieHasBeenUpdatedNotification";
//NSString *const GroupSelfiesHaveBeenRefreshedNotification              = @"groupSelfie.groupSelfiesHaveBeenRefreshedNotification";

NSString *const kAcceptConditionsKey = @"acceptConditions";

#pragma mark - Colors

float const color1Red = 239.0f/255.0f;
float const color1Green = 91.0f/255.0f;
float const color1Blue = 48.0f/255.0f;

float const color2Red = 71.0f/255.0f;
float const color2Green = 71.0f/255.0f;
float const color2Blue = 71.0f/255.0f;

float const color3Red = 30.0f/255.0f;
float const color3Green = 30.0f/255.0f;
float const color3Blue = 30.0f/255.0f;

float const lightGrayRed = 160.0f/255.0f;
float const lightGrayGreen = 160.0f/255.0f;
float const lightGrayBlue = 160.0f/255.0f;

float const backgroundGrayRed = 229.0f/255.0f;
float const backgroundGrayGreen = 229.0f/255.0f;
float const backgroundGrayBlue = 229.0f/255.0f;

#pragma mark - Image

int const canvasImage = 350;

float const searchButtonHeight = 45.0f;

#pragma mark - Objects

// Field keys
NSString *const kCreatedAt      = @"createdAt";
NSString *const kLocalCreatedAt = @"localCreatedAt";
NSString *const kObjectIdKey    = @"objectId";

#pragma mark - Installation Class

// Field keys
NSString *const kInstallationUserKey = @"user";

#pragma mark - User Class

// Class key
NSString *const kUserClassKey = @"_User";

// Function keys
NSString *const kUserFunctionKey          = @"updateUser";
NSString *const kUserFunctionUsernameKey  = @"username";
NSString *const kUserFunctionPasswordKey  = @"password";
NSString *const kUserFunctionVerifCodeKey = @"verifCode";
NSString *const kUserFunctionCheckUserKey    = @"checkUser";
NSString *const kUserFunctionAcceptConditionsKey    = @"acceptConditions";

// Field keys
NSString *const kUserNumberFriendsKey    = @"nFriends";
NSString *const kUserPhotoIdKey          = @"photoId";
NSString *const kUserTypeKey             = @"type";
NSString *const kUserAvailableFromKey    = @"availableFrom";
NSString *const kUserAvailableToKey      = @"availableTo";
NSString *const kUserLocationKey         = @"location";

NSString *const kTypeRegularKey     = @"regular";
NSString *const kTypeEventKey       = @"event";

#pragma mark - Activity Class

// Class key
NSString *const kActivityClassKey = @"Activity";

// Field keys
NSString *const kActivityFromUsernameKey    = @"fromUsername";
NSString *const kActivityTypeKey            = @"type";
NSString *const kActivityToGroupSelfieIdKey = @"toGroupSelfieId";
NSString *const kActivityContentKey         = @"content";

// Type values
NSString *const kActivityTypeCreatedKey      = @"cr";
NSString *const kActivityTypeParticipatedKey = @"pa";
NSString *const kActivityTypeCommentedKey    = @"co";
NSString *const kActivityTypeVotedKey        = @"vo";
NSString *const kActivityTypeReVotedKey      = @"rv";

#pragma mark - Relationship Class

// Class key
NSString *const kRelationshipClassKey = @"Relationship";

// Function keys
NSString *const kRelationshipFunctionKey          = @"updateRelationships";
NSString *const kRelationshipFunctionContactsKey  = @"contacts";
NSString *const kRelationshipSponsoredFunctionKey = @"checkHasSponsoredRelationships";

// Field keys
NSString *const kRelationshipFromUserKey         = @"fromUser";
NSString *const kRelationshipToUserIdKey         = @"toUserId";
NSString *const kRelationshipToUsernameKey       = @"toUsername";

NSString *const kRelationshipActiveKey           = @"active";

NSString *const kRelationshipTypeKey             = @"type";
NSString *const kRelationshipTypeSingle          = @"s";
NSString *const kRelationshipTypeGroup           = @"g";

NSString *const kRelationshipNumberComSelfiesKey      = @"nComSelfies";
NSString *const kRelationshipLocalNumberComSelfiesKey = @"local_nComSelfies";

#pragma mark - GroupSelfie Class

// Class key
NSString *const kGroupSelfieClassKey = @"GroupSelfie";

// Function keys
NSString *const kGroupSelfieFunctionAddParticipatedIdKey  = @"addParticipatedId";
NSString *const kGroupSelfieFunctionAddSeenIdKey          = @"addSeenId";
NSString *const kGroupSelfieFunctionUserKey               = @"user";

NSString *const kGroupSelfieFunctionIdKey        = @"groupSelfie_id";

// Field keys
NSString *const kGroupSelfieImageKey          = @"image";
NSString *const kGroupSelfieImageSmallKey     = @"imageSmall";
NSString *const kGroupSelfieLocalCreatedAtKey = @"localCreatedAt";

NSString *const kGroupSelfieHashtagKey        = @"hashtag";

NSString *const kGroupSelfieTypeKey           = @"type";
NSString *const kGroupSelfieTypeChallengeKey  = @"c";
NSString *const kGroupSelfieTypePostKey       = @"p";

NSString *const kGroupSelfieGroupIdsKey            = @"groupIds";
NSString *const kGroupSelfieGroupUsernamesKey      = @"groupUsernames";
NSString *const kGroupSelfieParticipatedIdsKey     = @"participatedIds";
NSString *const kGroupSelfieSeenIdsKey             = @"seenIds";
NSString *const kGroupSelfieLocalSeenIdsKey        = @"localSeenIds";
NSString *const kGroupSelfieImprovedAtKey          = @"improvedAt";
NSString *const kGroupSelfieLocalImprovedAtKey     = @"localImprovedAt";
NSString *const kGroupSelfieClosedKey              = @"closed";

#pragma mark - SingleSelfie Class

// Class key
NSString *const kSingleSelfieClassKey = @"SingleSelfie";

// Field keys
NSString *const kSingleSelfieImageKey           = @"image";
NSString *const kSingleSelfieToGroupSelfieIdKey = @"toGroupSelfieId";

#pragma mark - Verification Class

// Function keys
NSString *const kVerificationFunctionKey = @"newVerifCodeForPhoneNumber";
NSString *const kVerificationFunctionPhoneNumberKey = @"phoneNumber";

#pragma mark - User Defaults

// Field keys
NSString *const kUserDefaultsDidCallNetwork = @"didCallNetwork";
NSString *const kUserDefaultsPinNames       = @"pinNames";
NSString *const kUserDefaultsUsernameKey    = @"userDefaultsUsername";
NSString *const kUserDefaultsObjectIdKey    = @"userDefaultsObjectId";

#pragma mark - Push Notification Payload Keys

NSString *const kPushPayloadPayloadKey             = @"p";
NSString *const kPushPayloadPayloadActivityKey     = @"a";
//NSString *const kPushPayloadPayloadGroupSelfieKey  = @"gs";
NSString *const kPushPayloadPayloadRelationshipKey = @"rl";

NSString *const kPushPayloadTypeKey                  = @"ty";
NSString *const kPushPayloadTypeCreatedKey           = @"cr";
NSString *const kPushPayloadTypeParticipatedKey      = @"pa";
NSString *const kPushPayloadTypeCommentedKey         = @"co";
NSString *const kPushPayloadTypeVotedKey             = @"vo";
NSString *const kPushPayloadTypeReVotedKey           = @"rv";

NSString *const kPushPayloadIdKey               = @"id";
NSString *const kPushPayloadFromUsernameKey     = @"fu";
NSString *const kPushPayloadFromUserIdKey       = @"fui";
NSString *const kPushPayloadToGroupSelfieIdKey  = @"tg";
NSString *const kPushPayloadContentKey          = @"co";
NSString *const kPushPayloadCreatedAtKey        = @"ca";
NSString *const kPushPayloadParticipatedKey     = @"pa";
NSString *const kPushPayloadVoteIdsKey          = @"vo";

// Double constants
double const kDelay = 7.0;



