//
//  DetailsViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "DetailsViewController.h"

#import "CustomNavigationController.h"
#import "MBProgressHUD.h"
#import "Constants.h"

#import "TTTTimeIntervalFormatter.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface DetailsViewController ()

@property (nonatomic, strong) NSMutableArray *usernames;
@property (nonatomic, strong) NSMutableArray *userIds;

@end

@implementation DetailsViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _usernames = [[NSMutableArray alloc] init];
        _userIds = [[NSMutableArray alloc] init];
        
        timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapBackButtonAction:)];
    [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [self.tableView addGestureRecognizer:swipe];
    
    [self updateTitleView];
    
    for (int index = 0; index < [self.groupSelfie.groupUsernames count]; index++) {
        NSString *username = self.groupSelfie.groupUsernames[index];
        if (![username isEqualToString:[PFUser currentUser].username]) {
            [self.usernames addObject:username];
            [self.userIds addObject:self.groupSelfie.groupIds[index]];
        }
    }
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneBookUpdatedNotification:) name:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (void)phoneBookUpdatedNotification:(NSNotification *)note {
    [self.tableView reloadData];
}

- (void)updateTitleView {
    
    UILabel *hashtagLabel = [[UILabel alloc] init];
    hashtagLabel.frame = CGRectMake(0, 0, 200, self.navigationController.view.frame.size.height);
    hashtagLabel.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@\n",self.groupSelfie.hashtag] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f], NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    NSDate *date = self.groupSelfie.createdAt;
    NSString *string = [timeFormatter formatDate:date givenDate:[NSDate date]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f], NSForegroundColorAttributeName:[UIColor blackColor]}]];
    
    hashtagLabel.attributedText = attributedString;
    hashtagLabel.numberOfLines = 0;
    hashtagLabel.textAlignment = NSTextAlignmentCenter;

    
    self.navigationItem.titleView = hashtagLabel;
    
    
}

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSwipe:(UIPanGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usernames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PhoneBook *phoneBook = [PhoneBook sharedInstance];
    
    
    
    float fontSize = 16.0f;
    
    NSMutableAttributedString *attributedString;
    NSString *firstName = [phoneBook firstNameForUsername:self.usernames[indexPath.row]];
    if (firstName) {
        NSString *lastName = [phoneBook lastNameForUsername:self.usernames[indexPath.row]];
        if (lastName) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:firstName attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName:[UIColor blackColor]}];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", lastName] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize], NSForegroundColorAttributeName:[UIColor blackColor]}]];
        } else {
            attributedString = [[NSMutableAttributedString alloc] initWithString:firstName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize], NSForegroundColorAttributeName:[UIColor blackColor]}];
        }
    } else {
        attributedString = [[NSMutableAttributedString alloc] initWithString:[phoneBook nameForUsername:self.usernames[indexPath.row]] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
    
    cell.textLabel.attributedText = attributedString;
    
    if ([[self.groupSelfie getRelevantParticipatedIds] containsObject:self.userIds[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *username = self.usernames[indexPath.row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    if ([numberFormatter numberFromString:username]) {
        
        PhoneBook *phoneBook = [PhoneBook sharedInstance];
        ABRecordRef person = [phoneBook personWithPhoneNumber:username];
        
        if (person) {
            
            ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
            [personViewController setDisplayedPerson:person];
            [personViewController setAllowsEditing:NO];
            [personViewController setPersonViewDelegate:self];
            
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(didTapBackButtonAction:)];
            [backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            personViewController.navigationItem.leftBarButtonItem = backButton;
            
            [[PhoneBook sharedInstance] setReloaded:NO];
            [self.navigationController pushViewController:personViewController animated:YES];
            
        } else {
            
            ABRecordRef newPerson = [PhoneBook createPersonWithPhoneNumber:[NSString stringWithFormat:@"+%@",username]];
            
            ABNewPersonViewController *personNewViewController = [[ABNewPersonViewController alloc] init];
            [personNewViewController setDisplayedPerson:newPerson];
            [personNewViewController setNewPersonViewDelegate:self];
            
            CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:personNewViewController];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor blackColor];
            navigationController.navigationBar.barTintColor = [UIColor whiteColor];
            
            [[PhoneBook sharedInstance] setReloaded:NO];
            [self presentViewController:navigationController animated:YES completion:nil];
            
            CFRelease(newPerson);
            
        }
        
    }
    
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return YES;
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
