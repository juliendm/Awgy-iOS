//
//  CountryTableViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "CountryTableViewController.h"
#import "CountryPicker.h"
#import "NBPhoneNumberUtil.h"

#import "Constants.h"

@interface CountryTableViewController ()

@property (nonatomic, strong) NSMutableArray *countryNames;
@property (nonatomic, strong) NSMutableArray *countryCodes;
@property (nonatomic, strong) NSMutableArray *countryPrefixes;

@end

@implementation CountryTableViewController

- (id)init {
    self = [super init];
    if (self) {
        
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        
        NSArray *countryPickerNames = [CountryPicker countryNames];
        NSArray *countryPickerCodes = [CountryPicker countryCodes];
        
        _countryNames = [[NSMutableArray alloc] init];
        _countryCodes = [[NSMutableArray alloc] init];
        _countryPrefixes = [[NSMutableArray alloc] init];
        
        for (int index = 0; index < [countryPickerCodes count]; index++) {
            NSString *countryPrefix = [phoneUtil countryCodeFromRegionCode:countryPickerCodes[index]];
            if (countryPrefix) {
                [_countryNames addObject:countryPickerNames[index]];
                [_countryCodes addObject:countryPickerCodes[index]];
                [_countryPrefixes addObject:countryPrefix];
            }
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Country Code";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    NSUInteger index = [self.countryCodes indexOfObject:self.selectedCountryCode];
    if (index != NSNotFound && index < [self.countryNames count]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.countryNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ +%@", self.countryNames[indexPath.row], self.countryPrefixes[indexPath.row]];
    
    if ([self.countryCodes[indexPath.row] isEqualToString:self.selectedCountryCode]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CountryCodeCountryCodeHasBeenUpdatedNotification object:nil userInfo:@{@"countryCode": self.countryPrefixes[indexPath.row]}];
    
    self.selectedCountryCode = self.countryCodes[indexPath.row];
    [self.tableView reloadData];

}

@end
