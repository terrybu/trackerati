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

@property (strong, nonatomic) NSMutableDictionary *sectionInformation;
@property (strong, nonatomic) NSMutableDictionary *rowInformation;
@property (strong, nonatomic) GPPSignIn *googleSignIn;
@property (strong, nonatomic) HistoryViewController *historyViewController;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;
@property (strong, nonatomic) UILabel *clientName;
@property (strong, nonatomic) UILabel *projectName;
@property (strong, nonatomic) UILabel *dateOfService;
@property (strong, nonatomic) UILabel *hourOfService;
@property (strong, nonatomic) UILabel *clientNameLabel;
@property (strong, nonatomic) UILabel *projectNameLabel;
@property (strong, nonatomic) UILabel *dateOfServiceLabel;
@property (strong, nonatomic) UILabel *hourOfServiceLabel;
@property (strong, nonatomic) UIView  *formView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) Firebase *fireBase;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *clientNameString;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *hourString;
@property (strong, nonatomic) NSString *projectNameString;
@property (strong, nonatomic) NSDictionary* datas;
@property (strong, nonatomic) CustonLabel* commentTextLabel;
@property (strong, nonatomic) UILabel *commentLabel;

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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlAction)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    messageLabel.text = @"Please Pull to Refresh";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [messageLabel sizeToFit];
    self.tableView.backgroundView = messageLabel;
    
}

-(void)setFormForQuickSubmisson{
    self.formView = [[UIView alloc]initWithFrame:CGRectMake(-330, 0, 300, 500)];
    self.clientName = [[UILabel alloc]initWithFrame:CGRectMake(95, 57+25, 194, 60)];
    self.projectName = [[UILabel alloc]initWithFrame:CGRectMake(95, 113, 194, 60)];
    self.dateOfService = [[UILabel alloc]initWithFrame:CGRectMake(95, 146, 194, 60)];
    self.hourOfService = [[UILabel alloc]initWithFrame:CGRectMake(95, 180, 58, 60)];
    self.clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 57+25, 58, 35)];
    self.projectNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 113, 58, 35)];
    self.dateOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 146, 58, 35)];
    self.hourOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 180, 58, 35)];
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 210, 58, 35)];
    self.commentTextLabel = [[CustonLabel alloc] initWithFrame:CGRectMake(95, 210, 194, 140)];
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(13, 360, 60, 30);
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.clipsToBounds = YES;
    [self.sendButton.layer setBorderWidth:0.5f];
    [self.sendButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendForm) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.frame = CGRectMake(95, 360, 60, 30);
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.cancelButton.clipsToBounds = YES;
    [self.cancelButton.layer setBorderWidth:0.5f];
    [self.cancelButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelForm) forControlEvents:UIControlEventTouchUpInside];
    [self.clientNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.clientName setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.projectName setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.dateOfService setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.clientNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.hourOfService setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.projectNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.dateOfServiceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.hourOfServiceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.commentTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    self.commentTextLabel.layer.cornerRadius = 5.0f;
    self.commentTextLabel.clipsToBounds = YES;
    [self.commentTextLabel.layer setBorderWidth:0.5f];
    [self.commentTextLabel.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.commentTextLabel setNumberOfLines:200];
    [self.commentTextLabel setUserInteractionEnabled:YES];
    [self.formView addSubview:self.clientName];
    [self.formView addSubview:self.projectName];
    [self.formView addSubview:self.dateOfService];
    [self.formView addSubview:self.hourOfService];
    [self.formView addSubview:self.clientNameLabel];
    [self.formView addSubview:self.projectNameLabel];
    [self.formView addSubview:self.dateOfServiceLabel];
    [self.formView addSubview:self.hourOfServiceLabel];
    [self.formView addSubview:self.sendButton];
    [self.formView addSubview:self.cancelButton];
    [self.formView addSubview:self.commentLabel];
    [self.formView addSubview:self.commentTextLabel];
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
    [[FireBaseManager connectivityURLsharedFireBase] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
        if([snapshot.value boolValue] && [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KCurrentUser]]) {
            [[DataParser sharedManager] loginSuccessful];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kStartLogInProcessNotification object:nil];
        }
    }];
}

-(void)sendForm{
    NSDictionary *history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
    if ([history objectForKey:self.dateString]) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this ?",self.dateString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
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
    [[self.fireBase childByAutoId] setValue:@{@"client":self.clientNameString,@"date":self.dateString,@"hour":self.hourString,@"project":self.projectNameString}];
    [self slideOutForm];
    [[LastSavedManager sharedManager] saveClient:self.clientNameString withProject:self.projectNameString andHour:self.hourString];
}

-(void)cancelForm{
    self.tableView.userInteractionEnabled = YES;
   [self slideOutForm];
}

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


-(void)slideForm{
    self.formView.frame = CGRectMake(-330, 0, 300, 400);
    CGRect frame = self.view.bounds;
    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.formView]];
    [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, frame.size.width-10, 0, 0)];
    [self.dynamicAnimator addBehavior:collisionBehavior];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.formView]];
    self.gravityBehavior.gravityDirection = CGVectorMake(1.0f, 0.0f);
    [self.dynamicAnimator addBehavior:_gravityBehavior];
}

-(void)slideOutForm{
    [self.dynamicAnimator removeBehavior:self.gravityBehavior];
    self.snapBehavior = [[UISnapBehavior alloc]initWithItem:self.formView snapToPoint:CGPointMake(-330, 0)];
    [self.dynamicAnimator addBehavior:self.snapBehavior];
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
    
    if (!cell) {
        cell = [[CustomMCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    cell.delegate =self;
    
    __weak typeof(self) weakSelf = self;
    
    UIColor *whiteColor = [UIColor whiteColor];
    UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
    UIImageView *eraseMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Erase.png"]];
    
    [cell setSwipeGestureWithView:checkMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:nil];
    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:nil];
    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSDictionary* data = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KcurrentUserClientList]];
        NSMutableDictionary *mutableData = [[NSMutableDictionary alloc]initWithDictionary:data];
        NSString *client = [weakSelf.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
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
            
            self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/%@",[HConstants kFireBaseURL],client,project,uniqueAddress]];
            [self.fireBase removeValue];
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
        
        self.tableView.userInteractionEnabled = NO;
        NSDate *date = [[NSDate alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        self.projectName.text = cell.project;
        [self.projectName sizeToFit];
        self.clientName.text = cell.client;
        [self.clientName sizeToFit];
        self.dateOfService.text = [formatter stringFromDate:date];
        [self.dateOfService sizeToFit];
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
        self.clientNameString = self.clientName.text;
        self.dateString = self.dateOfService.text;
        self.projectNameString = self.projectName.text;
        
        if ([[LastSavedManager sharedManager] getLastSavedCommentForClient:self.clientNameString withProject:self.projectNameString])  {
            self.commentTextLabel.text = [[LastSavedManager sharedManager] getLastSavedCommentForClient:self.clientNameString withProject:self.projectNameString];
        } else{
            self.commentTextLabel.text =@"<NONE>";
        }
        
        self.hourOfService.text = [[LastSavedManager sharedManager] getLastSavedHourForClient:self.clientNameString withProject:self.projectNameString withCurrentHour:@"8"];
        self.hourString = self.hourOfService.text;
        [self.hourOfService sizeToFit];
        
        [self slideForm];
        
    }
}

@end
