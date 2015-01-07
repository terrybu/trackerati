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

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Clients";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(historyAction:)];
    self.sectionInformation = [[NSMutableDictionary alloc]init];
    self.rowInformation = [[NSMutableDictionary alloc]init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.formView = [[UIView alloc]initWithFrame:CGRectMake(-500, 0, 300, 400)];
    self.clientName = [[UILabel alloc]initWithFrame:CGRectMake(95, 57, 194, 21)];
    self.projectName = [[UILabel alloc]initWithFrame:CGRectMake(95, 113, 194, 21)];
    self.dateOfService = [[UILabel alloc]initWithFrame:CGRectMake(95, 156, 194, 21)];
    self.hourOfService = [[UILabel alloc]initWithFrame:CGRectMake(95, 199, 58, 21)];
    self.clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 57, 58, 21)];
    self.projectNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 113, 58, 21)];
    self.dateOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 156, 58, 21)];
    self.hourOfServiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 200, 58, 21)];
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(33, 320, 226, 36);
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
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
    self.formView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.formView];
}

-(void)sendForm{
    [self slideOutForm];
}

-(void) loginUnsuccessful{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not login. Please try later" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil];
    [alertView show];
}

-(void) loadData{
    NSDictionary* datas = (NSDictionary*)[[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KcurrentUserClientList]];
    __block int count = 0;
    [datas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [self.sectionInformation setObject:obj forKey:[NSNumber numberWithInt:count]];
        [self.rowInformation setObject:key forKey:[NSNumber numberWithInt:count]];
        count++;
    }];
    [self.tableView reloadData];
}

- (void) historyAction:(UIBarButtonItem*)barButton{
    self.historyViewController = [[HistoryViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:self.historyViewController animated:YES];
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
    
    static NSString *CellIdentifier = @"Cell";
    
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
        [weakSelf slideForm];
    }];

    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"second 1\n");
    }];
    [cell setSwipeGestureWithView:eraseMark color:whiteColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"second 2\n");
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
    return [[self.rowInformation allKeys] count];
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

@end
