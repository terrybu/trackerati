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

@interface HistoryViewController ()<RecordTableViewCellProtocol>

@property (nonatomic, strong) NSDictionary *historyOfRecords;
@property (nonatomic, strong) NSArray* dateKeys;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
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

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSData *currentUserRecordsData = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
    self.historyOfRecords = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserRecordsData];
    self.dateKeys = [self.historyOfRecords allKeys];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)updateNewRecords{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *currentUserRecordsData = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
        self.historyOfRecords = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserRecordsData];
        self.dateKeys = [self.historyOfRecords allKeys];
        
        if (self.recordDetailViewController && self.selectedIndexPath && self.selectedIndexPath.row >= 0 && self.selectedIndexPath.section >= 0){
            if ([self.dateKeys count] > self.selectedIndexPath.section && [self.historyOfRecords objectForKey:[self.dateKeys objectAtIndex:self.selectedIndexPath.section]]
                && [((NSArray*)[self.historyOfRecords objectForKey:[self.dateKeys objectAtIndex:self.selectedIndexPath.section]]) count] > self.selectedIndexPath.row) {
                self.recordDetailViewController.record = [((NSArray*)[self.historyOfRecords objectForKey:[self.dateKeys objectAtIndex:self.selectedIndexPath.section]])objectAtIndex:self.selectedIndexPath.row];
            }
        }
        
        [self.tableView reloadData];
    });
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)logOutAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartLogOutProcessNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Record TableView Cell Delegate
-(void)didClickDetailButton:(NSIndexPath*)indexPath{
    self.selectedIndexPath = indexPath;
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
    
    NSLog(@"historyOfRecords: %@", self.historyOfRecords);

    NSMutableArray *records = [self.historyOfRecords objectForKey:[self.dateKeys objectAtIndex:indexPath.section]];
    NSLog(@"%@", records.description);
    
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

@end
