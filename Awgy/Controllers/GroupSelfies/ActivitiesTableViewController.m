//
//  ActivitiesTableViewController.m
//  Awgy
//
//  Created by Julien de Muelenaere on 1/18/15.
//  Copyright (c) 2015 Julien de Muelenaere. All rights reserved.
//

#import "ActivitiesTableViewController.h"
#import "ActivitiesTableViewCell.h"
#import "Activity.h"

#import "Constants.h"

@interface ActivitiesTableViewController ()

@end

@implementation ActivitiesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {

        self.parseClassName = kActivityClassKey;
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 20;
        
        self.isLocalBuildable = YES;
        self.descendingOrderCreatedAt = YES;
        self.reversed = YES;
        
    }
    return self;
}

- (void)setGroupSelfie:(GroupSelfie *)groupSelfie {
    _groupSelfie = groupSelfie;
    
    NSString *pinName = [GroupSelfie keyWithGroupSelfieId:groupSelfie.objectId];
    self.pinName = pinName;
    self.keyName = pinName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 5.0f)];
//    self.tableView.tableFooterView = footerView;
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    [self.tableView addGestureRecognizer:swipe];

}

- (void)didSwipeRight:(UIPanGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(activitiesTableViewController:didSwipeRightView:)]) {
        [self.delegate activitiesTableViewController:self didSwipeRightView:recognizer.view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.showingImage = NO;
    
    // NEEDED TO UPDATES DATES
    [self.tableView reloadData];
    
    [self scrollDown];
}

#pragma mark - Loading

- (BFTask *)objectsDidLoad {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [source setResult:@1];
    return source.task;
    
}

- (PFQuery *)queryForTable {
    PFQuery *query = [Activity query];
    [query whereKey:kActivityToGroupSelfieIdKey equalTo:self.groupSelfie.objectId];

    return query;
}

#pragma mark - Table View

- (void)scrollDown {
    if ([self.objects count]) {
        @try {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.objects count]-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } @catch (NSException * e) {
            
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(Activity *)object {
    
    NSString *reuseIdentifier = @"Cell";
    
    ActivitiesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[ActivitiesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    @try {
        NSInteger index = [self.objects count]-1-indexPath.row;
        Activity *activity = [self.objects objectAtIndex:index];
        [cell updateForActivity:activity onGroupSelfie:self.groupSelfie];
    } @catch (NSException * e) {

    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    @try {
        NSInteger index = [self.objects count]-1-indexPath.row;
        Activity *activity = [self.objects objectAtIndex:index];
        return [ActivitiesTableViewCell sizeThatFits:tableView.bounds.size forActivity:activity onGroupSelfie:self.groupSelfie].height;
    } @catch (NSException * e) {
        return 0.0;
    }

}

#pragma mark - Notification

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
    CGPoint fingerLocation = [scrollView.panGestureRecognizer locationInView:scrollView];

    CGPoint headerFingerLocation = [scrollView convertPoint:fingerLocation toView:self.headerView];
    CGPoint footerFingerLocation = [scrollView convertPoint:fingerLocation toView:self.footerView];
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
    
    if (velocity.y > fabs(velocity.x) && footerFingerLocation.y > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resignKeyboard" object:nil userInfo:nil];
    }
    
    if (velocity.y < -fabs(velocity.x) && headerFingerLocation.y - self.headerView.frame.size.height < 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollPictureUp" object:nil userInfo:nil];
    }
    
}

@end
