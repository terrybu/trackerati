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
#import <MCSwipeTableViewCell.h>
#import "FormViewController.h"
#import "FireBaseManager.h"
#import "DataParser.h"
#import "LogInManager.h"
#import "NewProjectViewController.h"

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
@property (strong, nonatomic) Firebase *fireBase;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSString *clientNameString;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *hourString;
@property (strong, nonatomic) NSString *projectNameString;

@property (strong, nonatomic) NSDictionary* datas;

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
    
    [self.tableView registerClass:[MCSwipeTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    self.formView = [[UIView alloc]initWithFrame:CGRectMake(-500, 0, 300, 400)];
    
    self.clientName = [[UILabel alloc]initWithFrame:CGRectMake(95, 57+35, 194, 60)];
    self.projectName = [[UILabel alloc]initWithFrame:CGRectMake(95, 113+25, 194, 60)];
    self.dateOfService = [[UILabel alloc]initWithFrame:CGRectMake(95, 156+25, 194, 60)];
    self.hourOfService = [[UILabel alloc]initWithFrame:CGRectMake(95, 199+25, 58, 60)];
    self.clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 57+35, 58, 35)];
    self.projectNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 113+25, 58, 35)];
    self.dateOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 156+25, 58, 35)];
    self.hourOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 200+25, 58, 35)];
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(33, 320, 226, 36);
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendForm) forControlEvents:UIControlEventTouchUpInside];
    [self.formView addSubview:self.clientName];
    [self.formView addSubview:self.projectName];
    [self.formView addSubview:self.dateOfService];
    [self.formView addSubview:self.hourOfService];
    [self.formView addSubview:self.clientNameLabel];
    [self.formView addSubview:self.projectNameLabel];
    [self.formView addSubview:self.dateOfServiceLabel];
    [self.formView addSubview:self.hourOfServiceLabel];
    [self.formView addSubview:self.sendButton];
    self.formView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.formView];
    
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    self.fireBase = [FireBaseManager recordURLsharedFireBase];
    [[self.fireBase childByAutoId] setValue:@{@"client":self.clientNameString,@"date":self.dateString,@"hour":self.hourString,@"project":self.projectNameString}];
    [self slideOutForm];
}

-(void) loginUnsuccessful{
    [self.refreshControl endRefreshing];
    [self loadData];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not login. Please try later" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil];
    [alertView show];
}

-(void) loadData{
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:section]];
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
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
    
    [cell setSwipeGestureWithView:checkMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSArray *rows = [weakSelf.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSDate *date = [[NSDate alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/DD/YYYY"];
        weakSelf.projectName.text = [rows objectAtIndex:indexPath.row];
        [weakSelf.projectName sizeToFit];
        weakSelf.clientName.text = [weakSelf.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        [weakSelf.clientName sizeToFit];
        weakSelf.dateOfService.text = [formatter stringFromDate:date];
        [weakSelf.dateOfService sizeToFit];
        weakSelf.hourOfService.text = @"8";
        [weakSelf.hourOfService sizeToFit];
        weakSelf.clientNameLabel.text = @"Client:";
        [weakSelf.clientNameLabel sizeToFit];
        weakSelf.projectNameLabel.text = @"Project:";
        [weakSelf.projectNameLabel sizeToFit];
        weakSelf.dateOfServiceLabel.text = @"Date";
        [weakSelf.dateOfServiceLabel sizeToFit];
        weakSelf.hourOfServiceLabel.text = @"Hour:";
        [weakSelf.hourOfServiceLabel sizeToFit];
        
        weakSelf.clientNameString = weakSelf.clientName.text;
        weakSelf.dateString = weakSelf.dateOfService.text;
        weakSelf.hourString = weakSelf.hourOfService.text;
        weakSelf.projectNameString = weakSelf.projectName.text;
        
        [weakSelf slideForm];
    }];

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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loadData];
        });
    }];
    
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    cell.textLabel.text = [rows objectAtIndex:indexPath.row];
    return cell;
    
}

-(void)slideForm{
    self.formView.frame = CGRectMake(-500, 0, 300, 400);
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
    self.snapBehavior = [[UISnapBehavior alloc]initWithItem:self.formView snapToPoint:CGPointMake(-500, 0)];
    [self.dynamicAnimator addBehavior:self.snapBehavior];
}

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

@end
