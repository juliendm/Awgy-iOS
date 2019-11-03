//
//  PhoneBook.h
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NBPhoneNumberUtil.h"

@interface PhoneBook : NSObject

@property (nonatomic, strong) NSMutableDictionary *name;
@property (nonatomic, strong) NSMutableDictionary *nameShort;

@property (nonatomic, strong) NSMutableDictionary *firstName;
@property (nonatomic, strong) NSMutableDictionary *lastName;

@property (nonatomic, strong) NSMutableArray *orderedPhoneNumbers;
@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic) BOOL reloaded;

+ (id)sharedInstance;

- (NSString *)nameForUsername:(NSString *)username;
- (NSString *)nameShortForUsername:(NSString *)username;

- (NSString *)firstNameForUsername:(NSString *)username;
- (NSString *)lastNameForUsername:(NSString *)username;

- (void)fetchPhoneBook;
- (void)setDataFromPerson:(ABRecordRef)person withNotification:(BOOL)notification;
- (void)removeDataFromPerson:(ABRecordRef)person;

- (ABRecordRef)personWithPhoneNumber:(NSString *)phoneNumber;
+ (ABRecordRef)createPersonWithPhoneNumber:(NSString *)phoneNumber;

- (void)clear;

@end
