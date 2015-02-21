//
//  HistoryViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "HistoryViewController.h"
#import "RecordTableViewCell.h"
#import "HConstants.h"
#import "LogInManager.h"
#import "RecordDetailViewController.h"
#import "Record.h"
#import "DataParseManager.h"

@interface HistoryViewController ()<RecordTableViewCellProtocol>

@property (nonatomic, strong) NSArray* dateKeys;
@property (nonatomic, strong) RecordDetailViewController *recordDetailViewController;

@end

@implementation HistoryViewController

static NSString *cellIdentifier = @"RecordTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"History";
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutAction)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewRecords) name:kStartGetUserRecordsProcessNotification object:nil];
}

-(void)updateNewRecords{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *currentUserRecordsData = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
        self.historyOfRecords = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserRecordsData];
        self.dateKeys = [self.historyOfRecords allKeys];
        [self.tableView reloadData];
    });
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[DataParseManager sharedManager] getUserRecords];
    if (self.historyOfRecords.count > 0)
        self.dateKeys = [self.historyOfRecords allKeys];
    [self.tableView reloadData];
}


- (void)logOutAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartLogOutProcessNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Record TableView Cell Delegate
-(void)didClickDetailButton:(NSIndexPath*)indexPath{
    self.recordDetailViewController =[[RecordDetailViewController alloc]initWithNibName:@"RecordDetailViewController" bundle:nil];
    self.recordDetailViewController.record = [((NSArray*)[self.historyOfRecords objectForKey:[self.dateKeys objectAtIndex:indexPath.section]])objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.recordDetailViewController animated:YES];
}


#pragma mark - Table View and Data Source Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dateKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *records = [self.historyOfRecords objectForKey:[self.dateKeys objectAtIndex:section]];
    return records.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.dateKeys objectAtIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSMutableArray *records = [self.historyOfRecords objectForKey:[self.dateKeys objectAtIndex:indexPath.section]];
    
    Record *record = [records objectAtIndex:indexPath.row];
    [cell setclientNameLabelString:record.clientName];
    [cell setprojectNameLabelString:record.projectName];
    [cell sethourLabelString:record.hourOfTheService];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
