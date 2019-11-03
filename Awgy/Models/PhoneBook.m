//
//  PhoneBook.m
//  Awgy
//
//  Created by Julien de Muelenaere on 18/1/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "PhoneBook.h"
#import <Parse/Parse.h>
#import "Constants.h"

#import "Relationship.h"

#import "AppDelegate.h"

@interface PhoneBook ()
@property (nonatomic, strong) NBPhoneNumberUtil *phoneUtil;
@property (nonatomic, strong) NSString *regionCode;
@property (nonatomic, strong) NSMutableDictionary *recordId;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic) ABAddressBookRef addressBook;

@property (nonatomic, strong) NSMutableDictionary *phoneNumbers;

@end

@implementation PhoneBook

- (void)dealloc {
    
    ABAddressBookUnregisterExternalChangeCallback(self.addressBook, addressBookUpdated, (__bridge void *)(self));
    
}

+ (id)sharedInstance {
    static PhoneBook *instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {

        _name = [[NSMutableDictionary alloc] init];
        _firstName = [[NSMutableDictionary alloc] init];
        _lastName = [[NSMutableDictionary alloc] init];
        _nameShort = [[NSMutableDictionary alloc] init];
        _recordId = [[NSMutableDictionary alloc] init];
        _numberFormatter = [[NSNumberFormatter alloc] init];
        
        _phoneNumbers = [[NSMutableDictionary alloc] init];
        _orderedPhoneNumbers = [[NSMutableArray alloc] init];
        
        _reloaded = NO;

    }
    
    return self;
}


- (NSString *)nameForUsername:(NSString *)username {
    
    NSString *name = [self.name objectForKey:username];
    if (!name) {
        if([self.numberFormatter numberFromString:username]) {
            name = [NSString stringWithFormat:@"+%@",username];
        } else {
            name = username;
        }
    }
    return name;

}

- (NSString *)nameShortForUsername:(NSString *)username {
    
    NSString *nameShort = [self.nameShort objectForKey:username];
    if (!nameShort) {
        if([self.numberFormatter numberFromString:username]) {
            nameShort = [NSString stringWithFormat:@"+%@",username];
        } else {
            nameShort = username;
        }
    }
    return nameShort;
    
}



- (NSString *)firstNameForUsername:(NSString *)username {
    
    NSString *firstName;
    if([self.numberFormatter numberFromString:username]) {
        firstName = [self.firstName objectForKey:username];
    } else {
        firstName = username;
    }
    return firstName;
    
}

- (NSString *)lastNameForUsername:(NSString *)username {
    
    NSString *lastName;
    if([self.numberFormatter numberFromString:username]) {
        lastName = [self.lastName objectForKey:username];
    } else {
        lastName = username;
    }
    return lastName;
    
}



- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = phoneNumber;
    
    _phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSString *nationalNumber = nil;
    NSNumber *countryCode = [_phoneUtil extractCountryCode:phoneNumber nationalNumber:&nationalNumber];
    _regionCode = [_phoneUtil getRegionCodeForCountryCode:countryCode];
    
    if (self.addressBook) ABAddressBookUnregisterExternalChangeCallback(self.addressBook, addressBookUpdated, (__bridge void *)(self));
    [self fetchPhoneBook];
    if (self.addressBook) ABAddressBookRegisterExternalChangeCallback(self.addressBook, addressBookUpdated, (__bridge void *)(self));
    
}

void addressBookUpdated(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    
    PhoneBook *phoneBookSelf = (__bridge PhoneBook *)context;
    if (!phoneBookSelf.reloaded) {
        
        NSLog(@"log_awgy: addressBookUpdated");
        
        phoneBookSelf.reloaded = YES;
        [phoneBookSelf fetchPhoneBook];
        [phoneBookSelf performSelector:@selector(resetReloaded) withObject:nil afterDelay:5.0];
    }
    
}

- (void) resetReloaded {
    NSLog(@"log_awgy: reset reloaded");
    self.reloaded = NO;
}

- (void)fetchPhoneBook {
    
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self applyFetchPhoneBook];
                });
            } else {
                //NSLog(@"User denied access; Display an alert telling user the contact could not be added");
                self.addressBook = nil;
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self applyFetchPhoneBook];
    } else {
        //NSLog(@"The user has previously denied access; Send an alert telling user to change privacy setting in settings app");
        self.addressBook = nil;
    }
    
}

- (void)applyFetchPhoneBook {

    [self.name removeAllObjects];
    [self.firstName removeAllObjects];
    [self.lastName removeAllObjects];
    [self.nameShort removeAllObjects];
    [self.phoneNumbers removeAllObjects];
    [self.recordId removeAllObjects];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(self.addressBook);
    
    for(int i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        [self setDataFromPerson:person withNotification:NO];
    }
    
    [self order];
    
    CFRelease(allPeople);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil userInfo:nil];

}

- (void)order {
    
    [self.orderedPhoneNumbers removeAllObjects];
    for (NSString *key in [self.phoneNumbers allKeys]) {
        [self.orderedPhoneNumbers addObject:self.phoneNumbers[key]];
    }

    [self.orderedPhoneNumbers sortUsingComparator:^NSComparisonResult(NSArray *phoneNumbers1, NSArray *phoneNumbers2) {
        NSString *name1 = [self.name objectForKey:[phoneNumbers1 firstObject]];
        if (!name1) name1 = [NSString stringWithFormat:@"+%@",[phoneNumbers1 firstObject]];
        NSString *name2 = [self.name objectForKey:[phoneNumbers2 firstObject]];
        if (!name2) name2 = [NSString stringWithFormat:@"+%@",[phoneNumbers2 firstObject]];
        return [name1 compare:name2];
    }];
}

- (void)setDataFromPerson:(ABRecordRef)person withNotification:(BOOL)notification {
    
    ABRecordID recordID = ABRecordGetRecordID(person);
    
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    firstName = [firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    lastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *name;

    
    if (!(firstName == (id)[NSNull null] || firstName.length == 0) && (lastName == (id)[NSNull null] || lastName.length == 0)) {
        name = firstName;
        lastName = nil;
    } else if ((firstName == (id)[NSNull null] || firstName.length == 0) && !(lastName == (id)[NSNull null] || lastName.length == 0)) {
        name = lastName;
        firstName = nil;
    } else if (!(firstName == (id)[NSNull null] || firstName.length == 0) && !(lastName == (id)[NSNull null] || lastName.length == 0)) {
        name = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    } else {
        name = @"No Name";
        firstName = nil;
        lastName = nil;
    }

    NSArray *componentsShort = [name componentsSeparatedByString:@" "];
    NSMutableString *nameShort = [NSMutableString string];
    [nameShort appendString:componentsShort[0]];
    if ([componentsShort count] > 1) {
        [nameShort appendString:@" "];
        for (int i = 1; i < [componentsShort count]; i++) {
            NSString *component = componentsShort[i];
            if (component.length > 0) {
                [nameShort appendString:[component substringToIndex:1]];
            }
        }
    }
    
    NSMutableArray *phoneNumbersForName = [[NSMutableArray alloc] init];
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        phoneNumber = [self filterPhoneNumber:phoneNumber];
        [self.name setObject:name forKey:phoneNumber];
        [self.nameShort setObject:nameShort forKey:phoneNumber];
        if (firstName) [self.firstName setObject:firstName forKey:phoneNumber];
        if (lastName) [self.lastName setObject:lastName forKey:phoneNumber];
        [phoneNumbersForName addObject:phoneNumber];
        [self.recordId setObject:[NSNumber numberWithInt:recordID] forKey:phoneNumber];
    }
    
    
    if ([phoneNumbersForName count]) {
        NSMutableArray *phoneNumbersAlreadyIn = [[self.phoneNumbers objectForKey:name] mutableCopy];
        if (phoneNumbersAlreadyIn) {
            for (NSString *phoneNumberForName in phoneNumbersForName) {
                if (![phoneNumbersAlreadyIn containsObject:phoneNumberForName]) [phoneNumbersAlreadyIn addObject:phoneNumberForName];
            }
            [self.phoneNumbers setObject:phoneNumbersAlreadyIn forKey:name];
        } else {
            [self.phoneNumbers setObject:phoneNumbersForName forKey:name];
        }
        
    }
    
    CFRelease(phoneNumbers);
    
    if (notification) {
        
        [self order];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil userInfo:nil];

    }

}

- (void)removeDataFromPerson:(ABRecordRef)person {
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        phoneNumber = [self filterPhoneNumber:phoneNumber];
        [self.name removeObjectForKey:phoneNumber];
        [self.firstName removeObjectForKey:phoneNumber];
        [self.lastName removeObjectForKey:phoneNumber];
        [self.nameShort removeObjectForKey:phoneNumber];
        
//        Relationship *relationship;
//        for (relationship in self.orderedRelationships) {
//            if ([relationship.toUsername isEqualToString:phoneNumber]) break;
//        }
//        [self.orderedRelationships removeObject:relationship];
        [self.recordId removeObjectForKey:phoneNumber];
    }
    
    CFRelease(phoneNumbers);
    
}

- (ABRecordRef)personWithPhoneNumber:(NSString *)phoneNumber {
    
    if (self.addressBook && [self.recordId objectForKey:phoneNumber]) return ABAddressBookGetPersonWithRecordID(self.addressBook, [[self.recordId objectForKey:phoneNumber] intValue]);
    return nil;
    
}

- (NSString *)filterPhoneNumber:(NSString *)phoneNumber {
    
    NSError *error = nil;
    NBPhoneNumber *number = [self.phoneUtil parse:phoneNumber defaultRegion:self.regionCode error:&error];
    if (!error) {
        //[phoneUtil isValidNumber:number]
        phoneNumber = [self.phoneUtil format:number numberFormat:NBEPhoneNumberFormatE164 error:&error];
    }
    
    return [phoneNumber stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];

}

+ (ABRecordRef)createPersonWithPhoneNumber:(NSString *)phoneNumber {
    
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFTypeRef)(phoneNumber), kABHomeLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, phoneNumbers, &error);
    CFRelease(phoneNumbers);
    return newPerson;
    
}

- (void)clear {
    
    [self.name removeAllObjects];
    [self.firstName removeAllObjects];
    [self.lastName removeAllObjects];
    [self.nameShort removeAllObjects];
    [self.phoneNumbers removeAllObjects];
    [self.orderedPhoneNumbers removeAllObjects];
    [self.recordId removeAllObjects];
    _phoneNumber = nil;
    _regionCode = nil;
    
}

@end
