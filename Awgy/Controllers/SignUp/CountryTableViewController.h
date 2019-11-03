//
//  CountryTableViewController.h
//  Awgy
//
//  Created by Julien de Muelenaere on 1/17/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryTableViewControllerDelegate;

@interface CountryTableViewController : UITableViewController

@property (nonatomic, strong) NSString *selectedCountryCode;

@property (nonatomic, weak) id<CountryTableViewControllerDelegate> delegate;

@end

@protocol CountryTableViewControllerDelegate <NSObject>
@optional

- (void)countryTableViewController:(CountryTableViewController *)countryTVC didSelectCountryCode:(NSString *)countryCode;

@end
