//
//  LogInViewController.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "LogInViewController.h"
#import "HistoryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HConstants.h"
#import "CustomMCSwipeTableViewCell.h"
#import "FormViewController.h"
#import "FireBaseManager.h"
#import "DataParser.h"
#import "LogInManager.h"
#import "NewProjectViewController.h"
#import "LastSavedManager.h"
#import "CustonLabel.h"


@interface LogInViewController ()<MCSwipeTableViewCellDelegate>

// Data Source
@property (strong, nonatomic) NSMutableDictionary *sectionInformation;
@property (strong, nonatomic) NSMutableDictionary *rowInformation;
@property (strong, nonatomic) NSDictionary* datas;

@property (strong, nonatomic) GPPSignIn *googleSignIn;

@property (strong, nonatomic) HistoryViewController *historyViewController;

@property (strong, nonatomic) Firebase *fireBase;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSDateFormatter *formatter;

// Elements for the quick form
@property (strong, nonatomic) UIView  *formView;
@property (strong, nonatomic) UILabel *projectTextLabel;
@property (strong, nonatomic) UILabel *dateOfServiceTextLabel;
@property (strong, nonatomic) UILabel *hourOfServiceTextLabel;
@property (strong, nonatomic) UILabel *clientNameLabel;
@property (strong, nonatomic) UILabel *projectNameLabel;
@property (strong, nonatomic) UILabel *dateOfServiceLabel;
@property (strong, nonatomic) UILabel *hourOfServiceLabel;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) CustonLabel* commentTextLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) UILabel *clientNameTextLabel;
@property (strong, nonatomic) UILabel *typeTextLabel;
@property (strong, nonatomic) UILabel *statusTextLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *statusLabel;

// Animations for the quick form
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;

@end

@implementation LogInViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Enter your hours";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(historyAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProjects)];
    
    self.sectionInformation = [[NSMutableDictionary alloc]init];
    self.rowInformation = [[NSMutableDictionary alloc]init];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[CustomMCSwipeTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    [self setFormForQuickSubmisson];
    [self.view addSubview:self.formView];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlAction)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    messageLabel.text = @"Pull to refresh / Click + to add your projects";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [messageLabel sizeToFit];
    self.tableView.backgroundView = messageLabel;
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MM/dd/yyyy"];
}

-(void)setFormForQuickSubmisson{
    self.formView = [[UIView alloc]initWithFrame:CGRectMake(-330, 0, 300, 500)];
    
    self.clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 82, 58, 35)];
    self.projectNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 113, 58, 35)];
    self.dateOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 146, 58, 35)];
    self.hourOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 175, 58, 35)];
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 300, 58, 35)];
    self.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 215, 58, 35)];
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 260, 58, 35)];
    
    self.clientNameTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 82, 194, 35)];
    self.projectTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 113, 194, 35)];
    self.dateOfServiceTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 146, 194, 35)];
    self.hourOfServiceTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 167, 194, 35)];
    self.commentTextLabel = [[CustonLabel alloc] initWithFrame:CGRectMake(95, 300, 194, 130)];
    self.typeTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 215-8, 194, 35)];
    self.statusTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 260-8, 194, 35)];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(13, 450, 60, 30);
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.clipsToBounds = YES;
    [self.sendButton.layer setBorderWidth:0.5f];
    [self.sendButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendForm) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.frame = CGRectMake(95, 450, 60, 30);
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.cancelButton.clipsToBounds = YES;
    [self.cancelButton.layer setBorderWidth:0.5f];
    [self.cancelButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelForm) forControlEvents:UIControlEventTouchUpInside];
    
    [self.clientNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.clientNameTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.projectTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.dateOfServiceTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.clientNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.hourOfServiceTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.projectNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.dateOfServiceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.hourOfServiceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.typeLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.statusLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.typeTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.statusTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    
    [self.commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.commentTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    self.commentTextLabel.layer.cornerRadius = 5.0f;
    self.commentTextLabel.clipsToBounds = YES;
    [self.commentTextLabel.layer setBorderWidth:0.5f];
    [self.commentTextLabel.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.commentTextLabel setNumberOfLines:200];
    [self.commentTextLabel setUserInteractionEnabled:YES];
    
    self.clientNameLabel.text = @"Client:";
    [self.clientNameLabel sizeToFit];
    self.projectNameLabel.text = @"Project:";
    [self.projectNameLabel sizeToFit];
    self.dateOfServiceLabel.text = @"Date:";
    [self.dateOfServiceLabel sizeToFit];
    self.hourOfServiceLabel.text = @"Hour:";
    [self.hourOfServiceLabel sizeToFit];
    self.commentLabel.text = @"Comment:";
    [self.commentLabel sizeToFit];
    self.typeLabel.text = @"Type:";
    [self.typeLabel sizeToFit];
    self.statusLabel.text = @"Status:";
    [self.statusLabel sizeToFit];
    
    [self.formView addSubview:self.clientNameTextLabel];
    [self.formView addSubview:self.projectTextLabel];
    [self.formView addSubview:self.dateOfServiceTextLabel];
    [self.formView addSubview:self.hourOfServiceTextLabel];
    [self.formView addSubview:self.clientNameLabel];
    [self.formView addSubview:self.projectNameLabel];
    [self.formView addSubview:self.dateOfServiceLabel];
    [self.formView addSubview:self.hourOfServiceLabel];
    [self.formView addSubview:self.sendButton];
    [self.formView addSubview:self.cancelButton];
    [self.formView addSubview:self.commentLabel];
    [self.formView addSubview:self.commentTextLabel];
    [self.formView addSubview:self.typeLabel];
    [self.formView addSubview:self.statusLabel];
    [self.formView addSubview:self.typeTextLabel];
    [self.formView addSubview:self.statusTextLabel];
    
    self.formView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f/1.0f];
    self.formView.layer.cornerRadius = 5.0f;
    self.formView.clipsToBounds = YES;
    [self.formView.layer setBorderWidth:0.5f];
    [self.formView.layer setBorderColor:[UIColor grayColor].CGColor];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

-(void)refreshControlAction{
    
    Reachability* curReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [curReach currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[FireBaseManager connectivityURLsharedFireBase] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
                if([snapshot.value boolValue] && [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KCurrentUser]]) {
                    [[DataParser sharedManager] loginSuccessful];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kStartLogInProcessNotification object:nil];
                }
            }];
        });
    } else {
        [self loginUnsuccessful];
    }
    
}

-(void)sendForm{
    NSDictionary *history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
    if ([history objectForKey:self.dateOfServiceTextLabel.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this ?",self.dateOfServiceTextLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
    } else{
        [self sendData];
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Send"]) {
        [self sendData];
    }else{
        self.tableView.userInteractionEnabled = YES;
        [self slideOutForm];
    }
}

-(void)sendData{
    self.tableView.userInteractionEnabled = YES;
    self.fireBase = [FireBaseManager recordURLsharedFireBase];
    
    if (self.commentTextLabel.text && [self.commentTextLabel.text length] > 0) {
        [[self.fireBase childByAutoId] setValue:@{@"client":self.clientNameTextLabel.text,@"date":self.dateOfServiceTextLabel.text,@"hour":self.hourOfServiceTextLabel.text,@"project":self.projectTextLabel.text,@"status":(([self.statusTextLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeTextLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0"),@"comment":self.commentTextLabel.text}];
        
        [[LastSavedManager sharedManager] saveRecord:@{@"client":self.clientNameTextLabel.text,@"date":self.dateOfServiceTextLabel.text,@"hour":self.hourOfServiceTextLabel.text,@"project":self.projectTextLabel.text,@"status":(([self.statusTextLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeTextLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0"),@"comment":self.commentTextLabel.text}];
    } else{
        [[self.fireBase childByAutoId] setValue:@{@"client":self.clientNameTextLabel.text,@"date":self.dateOfServiceTextLabel.text,@"hour":self.hourOfServiceTextLabel.text,@"project":self.projectTextLabel.text,@"status":(([self.statusTextLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeTextLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
        
        [[LastSavedManager sharedManager] saveRecord:@{@"client":self.clientNameTextLabel.text,@"date":self.dateOfServiceTextLabel.text,@"hour":self.hourOfServiceTextLabel.text,@"project":self.projectTextLabel.text,@"status":(([self.statusTextLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeTextLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
    }
    
    [self slideOutForm];
    
}

- (void) historyAction:(UIBarButtonItem*)barButton{
    self.historyViewController = [[HistoryViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:self.historyViewController animated:YES];
}

- (void)addNewProjects{
    NewProjectViewController *newProjectViewController = [[NewProjectViewController alloc]initWithNibName:@"NewProjectViewController" bundle:nil];
    [self.navigationController pushViewController:newProjectViewController animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Parser Delegate Methods

-(void) loginUnsuccessful{
    [self.refreshControl endRefreshing];
    [self loadData];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not login. Please try later" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil];
    [alertView show];
}

-(void) loadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        self.datas = (NSDictionary*)[[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KcurrentUserClientList]];
        __block int count = 0;
        __weak typeof(self) weakSelf = self;
        self.sectionInformation = nil;
        self.rowInformation = nil;
        self.sectionInformation = [[NSMutableDictionary alloc]init];
        self.rowInformation = [[NSMutableDictionary alloc]init];
        [self.datas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            [weakSelf.sectionInformation setObject:obj forKey:[NSNumber numberWithInt:count]];
            [weakSelf.rowInformation setObject:key forKey:[NSNumber numberWithInt:count]];
            count++;
        }];
        [self.tableView reloadData];
    });
}

#pragma mark - Form Methods


-(void)slideForm{
    self.formView.frame = CGRectMake(-330, 0, 300, 500);
    CGRect frame = self.view.bounds;
    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.formView]];
    [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, frame.size.width-10, 0, 0)];
    [self.dynamicAnimator addBehavior:collisionBehavior];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.formView]];
    self.gravityBehavior.gravityDirection = CGVectorMake(1.0f, 0.0f);
    [self.dynamicAnimator addBehavior:_gravityBehavior];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)slideOutForm{
    [self.dynamicAnimator removeBehavior:self.gravityBehavior];
    self.snapBehavior = [[UISnapBehavior alloc]initWithItem:self.formView snapToPoint:CGPointMake(-330, 0)];
    [self.dynamicAnimator addBehavior:self.snapBehavior];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)cancelForm{
    self.tableView.userInteractionEnabled = YES;
    [self slideOutForm];
}

#pragma mark - Table View and Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([[self.rowInformation allKeys] count] && [[self.rowInformation allKeys] count] > 0) {
        self.tableView.backgroundView.hidden = YES;
        return [[self.rowInformation allKeys] count];
    } else{
        self.tableView.backgroundView.hidden = NO;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return (NSString*)[self.rowInformation objectForKey:[NSNumber numberWithInteger:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FormViewController *formViewController = [[FormViewController alloc]initWithNibName:@"FormViewController" bundle:nil];
    formViewController.isNewRecord = YES;
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    NSString *project = [rows objectAtIndex:indexPath.row];
    NSString *client = [self.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    formViewController.projectName = project;
    formViewController.clientName = client;
    [self.navigationController pushViewController:formViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:section]];
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomMCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate =self;
    
    __weak typeof(self) weakSelf = self;
    
    UIColor *whiteColor = [UIColor whiteColor];
    UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
    UIImageView *eraseMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Erase.png"]];
    
    [cell setSwipeGestureWithView:checkMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:nil];
    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:nil];
    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        
        //Swipe Left To Remove User From Selected Project
        NSDictionary* data = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KcurrentUserClientList]];
        NSMutableDictionary *mutableData = [[NSMutableDictionary alloc]initWithDictionary:data];
        NSString *client = [weakSelf.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSArray *rows = [weakSelf.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSString *project = [rows objectAtIndex:indexPath.row];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[mutableData objectForKey:client]];
        [tempArray removeObject:project];
        if ([tempArray count]== 0) {
            [mutableData removeObjectForKey:client];
        }else{
            [mutableData setObject:tempArray forKey:client];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:[HConstants KcurrentUserClientList]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
        __block NSString *uniqueAddress = nil;
        NSDictionary* rawMasterClientList = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kRawMasterClientList]];
        if ([[rawMasterClientList objectForKey:client]objectForKey:project]) {
            NSDictionary* rawUserList = [[rawMasterClientList objectForKey:client]objectForKey:project];
            [rawUserList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                if ([obj objectForKey:@"name"] && ([[obj objectForKey:@"name"]isEqualToString:username ])) {
                    uniqueAddress = key;
                    *stop = YES;
                    return;
                }
            }];
            
            weakSelf.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/%@",[HConstants kFireBaseURL],client,project,uniqueAddress]];
            [weakSelf.fireBase removeValue];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loadData];
        });
    }];
    
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    cell.textLabel.text = [rows objectAtIndex:indexPath.row];
    cell.project = [rows objectAtIndex:indexPath.row];
    cell.client = (NSString*)[self.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    return cell;
    
}

#pragma mark - CustomMCSwipeTableCell Delegate

- (void)swipeTableViewCell:(CustomMCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage{
    if (percentage > 0.0) {
        
        // Swipe Right To Trigger The Quick Form Submission
        
        self.tableView.userInteractionEnabled = NO;
        
        self.projectTextLabel.text = cell.project;
        [self.projectTextLabel sizeToFit];
        self.clientNameTextLabel.text = cell.client;
        [self.clientNameTextLabel sizeToFit];
        
        self.dateOfServiceTextLabel.text = [self.formatter stringFromDate:[NSDate date]];
        [self.dateOfServiceTextLabel sizeToFit];
        
        NSDictionary *lastSavedRecord = [[LastSavedManager sharedManager]getRecordForClient:self.clientNameTextLabel.text withProject:self.projectTextLabel.text];
        if (lastSavedRecord && [lastSavedRecord objectForKey:@"status"] && [lastSavedRecord objectForKey:@"type"] && [lastSavedRecord objectForKey:@"hour"]) {
            if ([lastSavedRecord objectForKey:@"comment"]) {
                self.commentTextLabel.text = [lastSavedRecord objectForKey:@"comment"];
            } else{
                self.commentTextLabel.text = nil;
            }
            if ([[lastSavedRecord objectForKey:@"status"] isEqualToString:@"1"]) {
                self.statusTextLabel.text = @"Full-Time Employee";
            }else {
                self.statusTextLabel.text = @"Part-Time Employee";
            }
            if ([[lastSavedRecord objectForKey:@"type"] isEqualToString:@"1"]) {
                self.typeTextLabel.text =  @"Billable Hour";
            }else {
                self.typeTextLabel.text =  @"Unbillable Hour";
            }
            self.hourOfServiceTextLabel.text = [lastSavedRecord objectForKey:@"hour"];
            
        }else{
            self.statusTextLabel.text = @"Full-Time Employee";
            self.typeTextLabel.text = @"Billable Hour";
            self.hourOfServiceTextLabel.text = @"8.0";
            if ([lastSavedRecord objectForKey:@"comment"]) {
                self.commentTextLabel.text = [lastSavedRecord objectForKey:@"comment"];
            } else{
                self.commentTextLabel.text = nil;
            }
        }
        
        [self slideForm];
        
    }
}

@end
