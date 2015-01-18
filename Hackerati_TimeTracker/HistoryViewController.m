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

@interface HistoryViewController ()<RecordTableViewCellProtocol>

@property (nonatomic, strong) NSDictionary *history;
@property (nonatomic, strong) NSArray* keys;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic, strong) RecordDetailViewController *recordViewController;

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
   
    self.history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
    self.keys = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecordsKeys]];
    
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
        self.history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
        self.keys = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecordsKeys]];

        if (self.recordViewController && self.selectedIndexPath && self.selectedIndexPath.row >= 0 && self.selectedIndexPath.section >= 0){
            if ([self.keys count] > self.selectedIndexPath.section && [self.history objectForKey:[self.keys objectAtIndex:self.selectedIndexPath.section]]
                && [((NSArray*)[self.history objectForKey:[self.keys objectAtIndex:self.selectedIndexPath.section]]) count] > self.selectedIndexPath.row) {
                self.recordViewController.record = [((NSArray*)[self.history objectForKey:[self.keys objectAtIndex:self.selectedIndexPath.section]])objectAtIndex:self.selectedIndexPath.row];
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
    self.recordViewController =[[RecordDetailViewController alloc]initWithNibName:@"RecordDetailViewController" bundle:nil];
    self.recordViewController.record = [((NSArray*)[self.history objectForKey:[self.keys objectAtIndex:indexPath.section]])objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.recordViewController animated:YES];
}

#pragma mark - Table View and Data Source Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.history objectForKey:[self.keys objectAtIndex:section]]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.keys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.keys objectAtIndex:section];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *record = [((NSArray*)[self.history objectForKey:[self.keys objectAtIndex:indexPath.section]])objectAtIndex:indexPath.row];
    
    [cell setclientNameLabelString:[record objectForKey:[HConstants kClient]]];
    [cell setprojectNameLabelString:[record objectForKey:[HConstants kProject]]];
    [cell sethourLabelString:[[record objectForKey:[HConstants kHour]] isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",[record objectForKey:[HConstants kHour]]]:[record objectForKey:[HConstants kHour]]];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

@end
