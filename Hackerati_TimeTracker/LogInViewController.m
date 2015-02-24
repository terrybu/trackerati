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
#import "RecordFormViewController.h"
#import "FireBaseManager.h"
#import "DataParseManager.h"
#import "LogInManager.h"
#import "NewProjectViewController.h"
#import "LastSavedManager.h"
#import "CustomLabel.h"
#import "Client.h"
#import "Project.h"
#import "User.h"
#import "Record.h"


@interface LogInViewController ()<CustomMCSwipeTableViewCellDelegate>

// Data Source
@property (strong, nonatomic) NSMutableArray* currentUserClientsArray;
@property (strong, nonatomic) NSMutableDictionary* recordsHistoryDictionary;

@property (strong, nonatomic) GPPSignIn *googleSignIn;
@property (strong, nonatomic) HistoryViewController *historyViewController;
@property (strong, nonatomic) Firebase *fireBase;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDateFormatter *formatter;

// Elements for Record quick form
@property (strong, nonatomic) UIView  *formView;
@property (strong, nonatomic) UILabel *projectTextLabel;
@property (strong, nonatomic) UILabel *dateOfServiceTextLabel;
@property (strong, nonatomic) UILabel *hourOfServiceTextLabel;
@property (strong, nonatomic) UILabel *clientNameLabel;
@property (strong, nonatomic) UILabel *projectNameLabel;
@property (strong, nonatomic) UILabel *dateOfServiceLabel;
@property (strong, nonatomic) UILabel *hourOfServiceLabel;

//Buttons for submitting/canceling the Record quick form
@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) CustomLabel* commentTextLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) UILabel *clientNameTextLabel;
@property (strong, nonatomic) UILabel *typeTextLabel;
@property (strong, nonatomic) UILabel *statusTextLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *statusLabel;

// Animations for Record quick form
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;

@end

@implementation LogInViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Your Projects";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(historyAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Pin More" style:UIBarButtonItemStyleBordered target:self action:@selector(addNewProjects)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[CustomMCSwipeTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
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

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    self.formView = [[UIView alloc]initWithFrame:CGRectMake(-self.view.frame.size.width-30, 0, self.view.frame.size.width-20, 500)];
    
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
    self.commentTextLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(95, 300, self.view.frame.size.width-126, 130)];
    
    self.typeTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 215-8, 194, 35)];
    self.statusTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 260-8, 194, 35)];
    
    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.submitButton.frame = CGRectMake(13, 450, 60, 30);
    self.submitButton.layer.cornerRadius = 5.0f;
    self.submitButton.clipsToBounds = YES;
    [self.submitButton.layer setBorderWidth:0.5f];
    [self.submitButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(sendForm) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.frame = CGRectMake(95, 450, 60, 30);
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.cancelButton.clipsToBounds = YES;
    [self.cancelButton.layer setBorderWidth:0.5f];
    [self.cancelButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelForm) forControlEvents:UIControlEventTouchUpInside];
    
    UIFont* helveticaFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
    [self.clientNameLabel setFont:helveticaFont];
    [self.clientNameTextLabel setFont:helveticaFont];
    [self.projectTextLabel setFont:helveticaFont];
    [self.dateOfServiceTextLabel setFont:helveticaFont];
    [self.clientNameLabel setFont:helveticaFont];
    [self.hourOfServiceTextLabel setFont:helveticaFont];
    [self.projectNameLabel setFont:helveticaFont];
    [self.dateOfServiceLabel setFont:helveticaFont];
    [self.hourOfServiceLabel setFont:helveticaFont];
    [self.typeLabel setFont:helveticaFont];
    [self.statusLabel setFont:helveticaFont];
    [self.typeTextLabel setFont:helveticaFont];
    [self.statusTextLabel setFont:helveticaFont];
    
    [self.commentLabel setFont:helveticaFont];
    [self.commentTextLabel setFont:helveticaFont];
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
    [self.formView addSubview:self.submitButton];
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
    
    [self.view addSubview:self.formView];
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
                    [[DataParseManager sharedManager] getAllDataFromFireBaseAfterLoginSuccess];
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
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
    self.recordsHistoryDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([self.recordsHistoryDictionary objectForKey:self.dateOfServiceTextLabel.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this ?",self.dateOfServiceTextLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
    } else{
        [self submitRecord];
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Send"]) {
        [self submitRecord];
    }
    else{
        self.tableView.userInteractionEnabled = YES;
        [self slideOutForm];
    }
}

-(void)submitRecord{
    //Two tables --> Users and Projects
    //When you are sending or submitting data here, it means to send a Record data to Records key under User key in Users table
    //However, when you are just adding a project to a user in NewProjectViewController, you are not dealing with Records table at all. You are dealing with Projects table --> Company key --> Project name and adding a uniqueID key that contains the username ex) terrythehackerati.com --> basically just registering a name under a project
    
    self.tableView.userInteractionEnabled = YES;
    self.fireBase = [FireBaseManager recordURLsharedFireBase];
    
    if (self.commentTextLabel.text && [self.commentTextLabel.text length] > 0) {
        [[self.fireBase childByAutoId] setValue:@{[HConstants kClient]:self.clientNameTextLabel.text,[HConstants kDate]:self.dateOfServiceTextLabel.text,[HConstants kHour]:self.hourOfServiceTextLabel.text,[HConstants kProject]:self.projectTextLabel.text,[HConstants kStatus]:(([self.statusTextLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeTextLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0"),[HConstants kComment]:self.commentTextLabel.text}];
        
        [[LastSavedManager sharedManager] saveRecord:@{[HConstants kClient]:self.clientNameTextLabel.text,[HConstants kDate]:self.dateOfServiceTextLabel.text,[HConstants kHour]:self.hourOfServiceTextLabel.text,[HConstants kProject]:self.projectTextLabel.text,[HConstants kStatus]:(([self.statusTextLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeTextLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0"),[HConstants kComment]:self.commentTextLabel.text}];
    } else{
        [[self.fireBase childByAutoId] setValue:@{[HConstants kClient]:self.clientNameTextLabel.text,[HConstants kDate]:self.dateOfServiceTextLabel.text,[HConstants kHour]:self.hourOfServiceTextLabel.text,[HConstants kProject]:self.projectTextLabel.text,[HConstants kStatus]:(([self.statusTextLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeTextLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0")}];
        
        [[LastSavedManager sharedManager] saveRecord:@{[HConstants kClient]:self.clientNameTextLabel.text,[HConstants kDate]:self.dateOfServiceTextLabel.text,[HConstants kHour]:self.hourOfServiceTextLabel.text,[HConstants kProject]:self.projectTextLabel.text,[HConstants kStatus]:(([self.statusTextLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeTextLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0")}];
    }
    
    [self slideOutForm];
    
}

- (void) historyAction:(UIBarButtonItem*)barButton{
    self.historyViewController = [[HistoryViewController alloc]initWithNibName:@"HistoryViewController" bundle:nil];
    self.historyViewController.recordsHistoryDictionary = self.recordsHistoryDictionary;
    [self.navigationController pushViewController:self.historyViewController animated:YES];
}

- (void)addNewProjects{
    NewProjectViewController *newProjectViewController = [[NewProjectViewController alloc]initWithNibName:@"NewProjectViewController" bundle:nil];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                               initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:newProjectViewController animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Parser Delegate Methods

-(void) loginUnsuccessful{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
        [self.refreshControl endRefreshing];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not login. Please try later" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil];
        [alertView show];
    });
}

-(void) loadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KcurrentUserClientList]];        
        self.currentUserClientsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    });
}

- (void) userRecordsDataReceived {
    NSData *currentUserRecordsData = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
    self.recordsHistoryDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserRecordsData];
}


#pragma mark - Form Methods
-(void)slideForm{
    self.formView.frame = CGRectMake(-self.view.frame.size.width-30, 0, self.view.frame.size.width-20, 500);
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
    self.snapBehavior = [[UISnapBehavior alloc]initWithItem:self.formView snapToPoint:CGPointMake(-self.view.frame.size.width-30, 0)];
    [self.dynamicAnimator addBehavior:self.snapBehavior];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)cancelForm{
    self.tableView.userInteractionEnabled = YES;
    [self slideOutForm];
}

#pragma mark - Record Table Cell Delegate

- (void)didPressCustomButton:(NSIndexPath*)indexPath {
    RecordFormViewController *recordFormViewController = [[RecordFormViewController alloc]initWithNibName:@"RecordFormViewController" bundle:nil];
    recordFormViewController.isNewRecord = YES;
    
    Client *client = [self.currentUserClientsArray objectAtIndex:indexPath.section];
    recordFormViewController.clientName = [client clientName];
    recordFormViewController.projectName = [client projectAtIndex:indexPath.row].projectName;
    [self.navigationController pushViewController:recordFormViewController animated:YES];
}

#pragma mark - Table View and Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.currentUserClientsArray.count > 0) {
        self.tableView.backgroundView.hidden = YES;
        return [self.currentUserClientsArray count];
    }
    self.tableView.backgroundView.hidden = NO;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Client *client = [self.currentUserClientsArray objectAtIndex:section];
    return client.clientName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    Client *client = [self.currentUserClientsArray objectAtIndex:section];
    return [client numberOfProjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomMCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate =self;
    Client *client = [self.currentUserClientsArray objectAtIndex:indexPath.section];
    Project *project = [client projectAtIndex:indexPath.row];
    
    UIColor *whiteColor = [UIColor whiteColor];
    UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
    UIImageView *eraseMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Erase.png"]];
    
    [cell setSwipeGestureWithView:checkMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:nil];
    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:nil];
    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        //Swipe Left To Remove User From Selected Project
        [self removeUserFromSelectedProject: client project:project];
    }];

    cell.textLabel.text = project.projectName;
    cell.project = project.projectName;
    cell.client = client.clientName;
    cell.customButton.indexPath = indexPath;
    return cell;
}

-(void)removeUserFromSelectedProject: (Client *) client project: (Project *) project {
    __weak typeof(self) weakSelf = self;
    [client.projects removeObject:project];
    if ([client.projects count]== 0) {
        [self.currentUserClientsArray removeObject:client];
    }
    NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
    [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants KcurrentUserClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
    __block NSString *uniqueAddress = nil;
    NSDictionary* rawMasterClientList = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kRawMasterClientList]];
    if ([[rawMasterClientList objectForKey:client.clientName]objectForKey:project.projectName]) {
        NSDictionary* rawUserList = [[rawMasterClientList objectForKey:client.clientName]objectForKey:project.projectName];
        [rawUserList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([obj objectForKey:@"name"] && ([[obj objectForKey:@"name"]isEqualToString:username ])) {
                uniqueAddress = key;
                *stop = YES;
                return;
            }
        }];
        weakSelf.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/%@",[HConstants kFireBaseURL],client.clientName, project.projectName, uniqueAddress]];
        [weakSelf.fireBase removeValue];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
    
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
        if (lastSavedRecord && [lastSavedRecord objectForKey:[HConstants kStatus]] && [lastSavedRecord objectForKey:[HConstants kType]] && [lastSavedRecord objectForKey:[HConstants kHour]]) {
            if ([lastSavedRecord objectForKey:[HConstants kComment]]) {
                self.commentTextLabel.text = [lastSavedRecord objectForKey:[HConstants kComment]];
            } else{
                self.commentTextLabel.text = nil;
            }
            if ([[lastSavedRecord objectForKey:[HConstants kStatus]] isEqualToString:@"1"]) {
                self.statusTextLabel.text = [HConstants KfullTimeEmployee];
            }else {
                self.statusTextLabel.text = [HConstants KpartTimeEmployee];
            }
            if ([[lastSavedRecord objectForKey:[HConstants kType]] isEqualToString:@"1"]) {
                self.typeTextLabel.text =  [HConstants KbillableHour];
            }else {
                self.typeTextLabel.text =  [HConstants KunbillableHour];
            }
            self.hourOfServiceTextLabel.text = [lastSavedRecord objectForKey:[HConstants kHour]];
            
        }else{
            self.statusTextLabel.text = [HConstants KfullTimeEmployee];
            self.typeTextLabel.text = [HConstants KbillableHour];
            self.hourOfServiceTextLabel.text = @"8.0";
            if ([lastSavedRecord objectForKey:[HConstants kComment]]) {
                self.commentTextLabel.text = [lastSavedRecord objectForKey:[HConstants kComment]];
            } else{
                self.commentTextLabel.text = nil;
            }
        }
        
        [self slideForm];
        
    }
}

@end
