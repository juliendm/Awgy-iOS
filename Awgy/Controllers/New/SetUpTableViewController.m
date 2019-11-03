//
//  SetUpTableViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "SetUpTableViewController.h"
#import "MainTableViewController.h"

#import "Constants.h"
#import "MBProgressHUD.h"
#import "Relationship.h"

#import "NavigationViewController.h"
#import "GroupViewController.h"

#import "UserTableViewCell.h"
#import "GroupTableViewCell.h"

#import "ActionTableViewCell.h"

#import "SingleSelfie.h"

#import "AppDelegate.h"

#import "Reachability.h"

@interface SetUpTableViewController ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic) BOOL isGif;

@property (nonatomic, strong) NSMutableArray *orderedPhoneNumbers;
@property (nonatomic, strong) NSMutableDictionary *nCommonSelfies;

@property (nonatomic, strong) NSString *hashtag;
@property (nonatomic, strong) NSMutableArray *groupUsernames;
@property (nonatomic, strong) NSMutableArray *activePhoneNumbers;

@property (nonatomic, strong) UITextField *hashtagField;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic) BOOL groupsIsEditing;
@property (nonatomic) BOOL contactsIsEditing;

@end

@implementation SetUpTableViewController

@dynamic delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.parseClassName = kRelationshipClassKey;
        
        self.pinName = kRelationshipClassKey;
        self.keyName = kRelationshipClassKey;
        
        self.cacheSubsetKey = kRelationshipActiveKey;
        self.cacheSubsetInverted = NO;
        self.cacheSubsetInPhoneBook = YES;
        
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = NO;
        
        _groupUsernames = [[NSMutableArray alloc] init];
        _activePhoneNumbers = [[NSMutableArray alloc] init];
        
        _nCommonSelfies = [[NSMutableDictionary alloc] init];
        
        PhoneBook *phoneBook = [PhoneBook sharedInstance];
        _orderedPhoneNumbers = [phoneBook.orderedPhoneNumbers mutableCopy];
        
        _groupsIsEditing = NO;
        _contactsIsEditing = NO;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneBookUpdatedNotification:) name:PhoneBookPhoneBookHasBeenUpdatedNotification object:nil];
    
}

#warning ADD KEYBOARDISSHOWING

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    self.groupsIsEditing = NO;
    self.contactsIsEditing = NO;
    [self.tableView reloadData];
    
    AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [appDelegate removePageViewControllerDataSource];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.groupUsernames removeAllObjects];
    
}

#pragma mark - Loading

- (BFTask *)objectsDidLoad {
    
    PhoneBook *phoneBook = [PhoneBook sharedInstance];
    self.orderedPhoneNumbers = [phoneBook.orderedPhoneNumbers mutableCopy];
    
    // Count and Filter
    [self.nCommonSelfies removeAllObjects];
    [self.activePhoneNumbers removeAllObjects];
    for (Relationship *relationship in self.objects) {
        [self.nCommonSelfies setObject:relationship.nComSelfies forKey:relationship.toUsername];
        if (relationship.toActive) [self.activePhoneNumbers addObject:relationship.toUsername];
    }
    
    for (NSUInteger index = 0; index < [self.orderedPhoneNumbers count]; index++) {
        NSArray *phoneNumbers = [self.orderedPhoneNumbers objectAtIndex:index];
        NSMutableArray *includedActivePhoneNumbers = [[NSMutableArray alloc] init];
        for (NSString *phoneNumber in phoneNumbers) {
            if ([self.activePhoneNumbers containsObject:phoneNumber]) [includedActivePhoneNumbers addObject:phoneNumber];
        }
        if ([includedActivePhoneNumbers count] > 0) self.orderedPhoneNumbers[index] = includedActivePhoneNumbers;
    }
    
    // Order
    [self.orderedPhoneNumbers sortUsingComparator:^NSComparisonResult(NSArray *phoneNumbers1, NSArray *phoneNumbers2) {
        
        NSNumber *nCommon1;
        for (NSString *phoneNumber in phoneNumbers1) {
            nCommon1 = [self.nCommonSelfies objectForKey:phoneNumber];
            if (nCommon1) break;
        }
        if (!nCommon1) nCommon1 = @0;
        
        NSNumber *nCommon2;
        for (NSString *phoneNumber in phoneNumbers2) {
            nCommon2 = [self.nCommonSelfies objectForKey:phoneNumber];
            if (nCommon2) break;
        }
        if (!nCommon2) nCommon2 = @0;
        return [nCommon2 compare:nCommon1];
        
    }];
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [source setResult:@1];
    return source.task;

}

- (BFTask *)didCallNetwork {
    
    [[Relationship updateRelationships:self.objects] continueWithBlock:^id(BFTask *task) {
        if (!task.error && task.result) {
            [self loadCache];
        }
        return nil;
    }];
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [source setResult:@1];
    return source.task;
    
}

- (PFQuery *)queryForTable {
    
    PFQuery *query = [Relationship query];
    query.limit = 1000;
    
    return query;
}

#pragma mark - Table View

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.orderedPhoneNumbers objectAtIndex:indexPath.row];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.groupSelfie.objectId) {
        return 1;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.groupSelfie.objectId) {
        return 4;
    } else {
        if (section == 0) {
            return 3;
        } else if (section == 1) {
            return 1;
        } else if (section == 2) {
            return [self.orderedPhoneNumbers count];
        } else {
            return 0;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.groupSelfie.objectId) {
        return nil;
    } else {
        if (section == 1) {
            return @"Groups";
        } else if (section == 2) {
            return @"Contacts";
        } else {
            return nil;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = [self tableView:tableView titleForHeaderInSection:section];
    CGFloat headerHeight = [self tableView:tableView heightForHeaderInSection:section];
    if (!headerTitle) return nil;
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(30.0f, 0.0, tableView.bounds.size.width-60.0f, headerHeight);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:color1Red green:color1Green blue:color1Blue alpha:1.0];
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    label.text = headerTitle;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, headerHeight);
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:label];
    
    UITapGestureRecognizer *singleTapRecogniser;
    singleTapRecogniser.delegate = self;
    if (section == 1) {
        singleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGroupsButtonAction:)];
    } else if (section == 2) {
        singleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContactsButtonAction:)];
    }
    [headerView addGestureRecognizer:singleTapRecogniser];
    
    return headerView;
}

- (void)didTapGroupsButtonAction:(id)sender {
    self.groupsIsEditing = !self.groupsIsEditing;
    [self.tableView reloadData];
}

- (void)didTapContactsButtonAction:(id)sender {
    self.contactsIsEditing = !self.contactsIsEditing;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        return 50.0f;
    } else {
        return 0.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
    
        if (indexPath.row == 0) {
            
            if (self.groupSelfie.objectId) {
                
                NSString *reuseIdentifier = @"InfoCell";
                
                ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
                if (cell == nil) {
                    cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                cell.actionLabel.text = @"Info";
                
                return cell;
            
            } else {
                
                NSString *reuseIdentifier = @"ActionCell";
                
                ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
                if (cell == nil) {
                    cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                cell.actionLabel.text = @"#HASHTAG";
                
                return cell;
            
            }
            
        } else if (indexPath.row == 1) {
            
            NSString *reuseIdentifier = @"ActionCell";
            
            ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil) {
                cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.actionLabel.text = @"SEND";
            
            //if (self.groupSelfie.objectId) {
            //    cell.detailTextLabel.text = nil;
            //} else {
            //    [self updateSendDetailsForCell:cell];
            //}
            
            return cell;
            
        } else if (indexPath.row == 2) {
            
            NSString *reuseIdentifier = @"ActionCell";
            
            ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil) {
                cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.actionLabel.text = @"CANCEL";
            
            return cell;
            
        } else if (self.groupSelfie.objectId && indexPath.row == 3) {
            
            NSString *reuseIdentifier = @"ActionCell";
            
            ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil) {
                cell = [[ActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.actionLabel.text = @"IGNORE";
            
            return cell;
            
        } else {
        
            return nil;
            
        }
        
    } else if (indexPath.section == 1) {

        
        NSString *reuseIdentifier = @"GroupCell";
        
        GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[GroupTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell updateForName:@"None" withNumber:@0];
        
        if (self.groupsIsEditing) {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
        
    } else if (indexPath.section == 2) {
        
        NSArray *phoneNumbers = (NSArray *)[self objectAtIndexPath:indexPath];
        
        NSString *reuseIdentifier = @"UserCell";
        
        UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (phoneNumbers) {
            NSString *username = [phoneNumbers firstObject];
            NSNumber *nCommon;
            for (NSString *phoneNumber in phoneNumbers) {
                nCommon = [self.nCommonSelfies objectForKey:phoneNumber];
                if (nCommon) break;
            }
            NSNumber *number = nCommon;
            [cell updateForUsername:username withNumber:number];
            for (NSString *phoneNumber in phoneNumbers) {
                if ([self.groupUsernames containsObject:phoneNumber]) {
                    [cell checkCell];
                    break;
                }
            }
        }
        
        if (self.contactsIsEditing) {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    
    } else {
        
        return nil;
        
    }
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return [ActionTableViewCell sizeThatFits:tableView.bounds.size].height;
    } else {
        return 50.0f;
    }

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int maxNumberPerGroupSelfie = 13;
    
    if (indexPath.section == 2) {
        NSArray *phoneNumbers = (NSArray *)[self objectAtIndexPath:indexPath];
        BOOL alreadyIn = NO;
        for (NSString *phoneNumber in phoneNumbers) {
            alreadyIn = [self.groupUsernames containsObject:phoneNumber];
            if (alreadyIn) break;
        }
        if ([self.groupUsernames count] < maxNumberPerGroupSelfie - 1 || alreadyIn) {
            return indexPath;
        } else  {
            if (self.navigationController.view) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                hud.color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"MAXIMUM_REACHED", nil);
                hud.detailsLabelText = [NSString stringWithFormat:NSLocalizedString(@"INFO_MAX_REACHED_%d", nil),maxNumberPerGroupSelfie-1];
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                [hud hide:YES afterDelay:1.5];
            }
            return nil;
        }
    } else {
        return indexPath;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
        
            self.hashtagField.text = @"Hashtag";
        
        } else if (indexPath.row == 1) {
        
            [self didTapSend];
        
        } else if (indexPath.row == 2) {
            
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController resetImage];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            [self.groupUsernames removeAllObjects];
            [self.tableView reloadData];
        
        } else if (self.groupSelfie.objectId && indexPath.row == 3) {
            
            if ([self isNetworkAvailable]) {
                
                // Ignore the invitation
                
                [[self.groupSelfie addParticipatedIdCallNetwork:YES] continueWithBlock:^id(BFTask *task) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController resetImage];
                        
                        [((MainTableViewController *)self.navigationController.viewControllers[0]).objects removeObject:self.groupSelfie];
                        [((MainTableViewController *)self.navigationController.viewControllers[0]).tableView reloadData];
                        
                        [self.navigationController popToRootViewControllerAnimated:NO];
                        [self.tableView reloadData];
                    });
                    
                    return nil;
                }];
                
            }
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (self.groupsIsEditing) {
            
            GroupViewController *groupViewController = [[GroupViewController alloc] init];
            NavigationViewController *navigationViewController = [[NavigationViewController alloc] initWithRootViewController:groupViewController];
            [self.navigationController pushViewController:navigationViewController animated:YES];
            
        } else {
        
            
        
        }
        
    } else if (indexPath.section == 2) {
        
        if (self.contactsIsEditing) {
            
            NSArray *phoneNumbers = (NSArray *)[self objectAtIndexPath:indexPath];
            if (phoneNumbers) {
                NSString *username = [phoneNumbers firstObject];
                PhoneBook *phoneBook = [PhoneBook sharedInstance];
                ABRecordRef person = [phoneBook personWithPhoneNumber:username];
                
                if (person) {
                    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
                    [personViewController setDisplayedPerson:person];
                    [personViewController setAllowsEditing:NO];
                    //[personViewController setPersonViewDelegate:self];
                    NavigationViewController *navigationViewController = [[NavigationViewController alloc] initWithRootViewController:personViewController];

                    [self.navigationController pushViewController:navigationViewController animated:YES];
                }
            }
        
        } else {
        
            UserTableViewCell *cell = (UserTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            NSArray *phoneNumbers = (NSArray *)[self objectAtIndexPath:indexPath];

            if (phoneNumbers) {
                
                NSString *alreadyInGroupWithNumber = nil;
                for (NSString *phoneNumber in phoneNumbers) {
                    if ([self.groupUsernames containsObject:phoneNumber]) {
                        alreadyInGroupWithNumber = phoneNumber;
                        break;
                    }
                }
                
                if (!alreadyInGroupWithNumber) {
                    if ([phoneNumbers count] == 1) {
                        [self.groupUsernames addObject:[phoneNumbers firstObject]];
                        [cell checkCell];
                    } else {
                        
                        self.selectedIndexPath = indexPath;
                        
                        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
                        actionSheet.delegate = self;
                        for (NSString *phoneNumber in phoneNumbers) {
                            [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"+%@",phoneNumber]];
                        }
                        [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
                        actionSheet.cancelButtonIndex = [phoneNumbers count];
                        
                        [actionSheet showInView:self.view];
                    }
                } else {
                    [self.groupUsernames removeObject:alreadyInGroupWithNumber];
                    [cell uncheckCell];
                }
                
            }
            
            [self updateSendDetailsForCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]];
            
        }
        
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    

    NSArray *phoneNumbers = (NSArray *)[self objectAtIndexPath:self.selectedIndexPath];
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {

    } else if (buttonIndex < [phoneNumbers count]) {
        UserTableViewCell *cell = (UserTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        [self.groupUsernames addObject:[phoneNumbers objectAtIndex:buttonIndex]];
        [cell checkCell];
    }
    
    self.selectedIndexPath = nil;
    
}

- (void)dismissKeyboard {
    [self.hashtagField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#define MAXLENGTHHASHTAG 15

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *tempString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    
    return ![textField.text isEqualToString:tempString] && textField.text.length - range.length + string.length <= MAXLENGTHHASHTAG;
    
}

#define MAXLENGTHDESCRIPTION 70

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *tempString = [[textView.text stringByReplacingCharactersInRange:range withString:text] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return ![textView.text isEqualToString:tempString] && textView.text.length - range.length + text.length <= MAXLENGTHDESCRIPTION;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if ([textView hasText]) {
        //self.placeHolderView.hidden = YES;
    } else {
        //self.placeHolderView.hidden = NO;
    }
    
}

- (void)processHashtag {
    
    NSData *data = [self.hashtagField.text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *hashtag = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    self.hashtag = [hashtag  stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    if (![self.hashtag length]) self.hashtag = nil;
    
}

- (void)didTapSend {
    
    self.groupsIsEditing = NO;
    self.contactsIsEditing = NO;
    [self.tableView reloadData];
    
    CameraViewController *cameraViewController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController;
    
    if (cameraViewController.filteredData) {
        self.data = cameraViewController.filteredData;
    } else {
        self.data = cameraViewController.data;
    }
    
    if (self.data) {
        self.isGif = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController.isGif;
        if (self.groupSelfie.objectId) {
            [self proceedExistingGroupSelfie];
        } else {
            [self createNewGroupSelfie];
        }
    }
    
}

- (void)proceedExistingGroupSelfie {
    
    if ([self isNetworkAvailable]) {

        PFFile *file = [PFFile fileWithName:self.isGif ? @"image.gif" : @"image.jpg" data:self.data];
        
        UIApplication * application = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[file saveInBackground] continueWithBlock:^id(BFTask *task) {
                
                if (!task.error && task.result) {
                    
                    SingleSelfie *singleSelfie = [SingleSelfie object];
                    singleSelfie.image = file;
                    singleSelfie.toGroupSelfieId = self.groupSelfie.objectId;
                    [singleSelfie saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (!succeeded || error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                                    message:[error localizedDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            });
                        }
                        
                        [application endBackgroundTask: background_task];
                        background_task = UIBackgroundTaskInvalid;
                        
                    }];
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                            message:NSLocalizedString(@"ERROR", nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        
                        [application endBackgroundTask: background_task];
                        background_task = UIBackgroundTaskInvalid;
                        
                    });
                    
                }
                
                return nil;
            }];
            
        });
        
        [[self.groupSelfie addParticipatedIdCallNetwork:NO] continueWithBlock:^id(BFTask *task) {

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController resetImage];
                
                [self.groupUsernames removeAllObjects];
                
                [((MainTableViewController *)self.navigationController.viewControllers[0]).objects removeObject:self.groupSelfie];
                [((MainTableViewController *)self.navigationController.viewControllers[0]).tableView reloadData];
                
                [self.navigationController popToRootViewControllerAnimated:NO];
                [self.tableView reloadData];
            });
            
            return nil;
        }];
        
    }
    
}

- (void)createNewGroupSelfie {
    
    [self dismissKeyboard];
    
    // Process
    [self processHashtag];
    self.hashtag = @"Hashtag"; //////////////////////////////////
    
    // Group
    PFUser *user = [PFUser currentUser];
    if (![self.groupUsernames containsObject:user.username]) {
        [self.groupUsernames addObject:user.username];
    }
    
    // Proceed
    
    if ([self.hashtag length] < 3) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                            message:NSLocalizedString(@"ERROR_NO_HASHTAG", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
    } else if ([self.groupUsernames count] <= 1) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                            message:NSLocalizedString(@"ERROR_NO_RECIPIENTS", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else if ([self isNetworkAvailable]) {
    
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:0.5];
        hud.removeFromSuperViewOnHide = YES;
        
        self.groupSelfie = [GroupSelfie object];
        self.groupSelfie.groupUsernames = self.groupUsernames;
        self.groupSelfie.hashtag = self.hashtag;
        self.groupSelfie.type = kGroupSelfieTypeChallengeKey;
        //self.groupSelfie.participatedIds = @[[PFUser currentUser].objectId]; DO NOT DO OTHERWISE CANNOT PARTICIPATE IN OWN GROUPSELFIE
        
        UIApplication * application = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[self.groupSelfie saveGroupSelfie] continueWithBlock:^id(BFTask *task) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (hud) [hud hide:YES];
                });
                
                if (!task.error && task.result) {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        PFFile *file = [PFFile fileWithName:self.isGif ? @"image.gif" : @"image.jpg" data:self.data];
                        
                        [[file saveInBackground] continueWithBlock:^id(BFTask *task) {
                            
                            if (!task.error && task.result) {
                                
                                SingleSelfie *singleSelfie = [SingleSelfie object];
                                singleSelfie.image = file;
                                singleSelfie.toGroupSelfieId = self.groupSelfie.objectId;
                                [singleSelfie saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    
                                    if (!succeeded || error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                                                message:[error localizedDescription]
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                      otherButtonTitles:nil];
                                            [alertView show];
                                        });
                                    }
                                    
                                    [application endBackgroundTask: background_task];
                                    background_task = UIBackgroundTaskInvalid;
                                    
                                }];
                                
                            } else {
                                
                                [application endBackgroundTask: background_task];
                                background_task = UIBackgroundTaskInvalid;
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                                        message:NSLocalizedString(@"ERROR", nil)
                                                                                       delegate:self
                                                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                              otherButtonTitles:nil];
                                    [alertView show];
                                    
                                });
                            }
                            
                            return nil;
                        }];

                    });
                    
                    NSMutableArray *nonActivePhoneNumbers = [[NSMutableArray alloc] init];
                    for (NSString *username in self.groupUsernames) {
                        if (![self.activePhoneNumbers containsObject:username] && ![username isEqualToString:user.username]) {
                            [nonActivePhoneNumbers addObject:username];
                        }
                    }
                    
                    [self.groupUsernames removeAllObjects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).baseViewController.pageViewController.cameraViewController resetImage];
                        
                        if ([nonActivePhoneNumbers count]) {
                            // SHOW SMS
                            if ([MFMessageComposeViewController canSendText]) {
                                
                                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                hud.color = [UIColor colorWithRed:color3Red green:color3Green blue:color3Blue alpha:0.8f];
                                hud.removeFromSuperViewOnHide = YES;
                                
                                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                                messageController.messageComposeDelegate = self;
                                [messageController setRecipients:nonActivePhoneNumbers];
                                [messageController setBody:@"Hello"];
                                messageController.navigationBar.translucent = NO;
                                messageController.navigationBar.barTintColor = [UIColor colorWithRed:color2Red green:color2Green blue:color2Blue alpha:1.0];
                                [self presentViewController:messageController animated:YES completion:^{[hud hide:YES];}];
                                
                            } else {
                                
                                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                                       message:NSLocalizedString(@"CANT_SEND_MESSAGES", nil)
                                                                                      delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                             otherButtonTitles:nil];
                                [warningAlert show];
                                
                            }
                            
                        } else {
                            
                            [self.navigationController popToRootViewControllerAnimated:NO];
                            [self.tableView reloadData];
                            
                        }
                        
                    });
                    
                    
                } else {
                    
                    [application endBackgroundTask: background_task];
                    background_task = UIBackgroundTaskInvalid;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alertView;
                        NSString *message = [task.error.userInfo objectForKey:@"error"];
                        NSArray *messages = [message componentsSeparatedByString:@"\n"];
                        
                        if ([messages count] > 1) {
                            NSArray *body_message = [messages subarrayWithRange:NSMakeRange(1,[messages count]-1)];
                            alertView = [[UIAlertView alloc] initWithTitle:messages[0]
                                                                   message:[body_message componentsJoinedByString:@"\n"]
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                         otherButtonTitles:nil];
                        } else {
                            alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                         otherButtonTitles:nil];
                        }
                        
                        [alertView show];
                        
                    });
                    
                }
                return nil;
            }];
            
        });
        
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil)
                                                                   message:NSLocalizedString(@"FAILED_SEND_MESSAGE", nil)
                                                                  delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                         otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.tableView reloadData];
}


- (void)updateSendDetailsForCell:(UITableViewCell *)cell {
    
    if (![self.groupUsernames count]) {
        cell.detailTextLabel.text = @"Visible by your friends";
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Challenge %lu",(unsigned long)[self.groupUsernames count]];
    }
    
}

#pragma mark - Notification center

- (void)phoneBookUpdatedNotification:(NSNotification *)note {
    [self loadNetwork];
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

#pragma mark - Network

- (BOOL)isNetworkAvailable {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    BOOL available = networkStatus != NotReachable;
    
    if (!available) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return available;
}

@end
