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

@interface HistoryViewController ()

@property (nonatomic, strong) NSDictionary *history;
@property (nonatomic, strong) NSArray* keys;

@end

@implementation HistoryViewController

static NSString *cellIdentifier = @"RecordTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"History";
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutAction)];
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

- (void)logOutAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartLogOutProcessNotification object:nil];
}

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
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }

    
    NSDictionary *record = [((NSArray*)[self.history objectForKey:[self.keys objectAtIndex:indexPath.section]])objectAtIndex:indexPath.row];
    
    [cell setclientNameLabelString:[record objectForKey:@"client"]];
    [cell setprojectNameLabelString:[record objectForKey:@"project"]];
    [cell sethourLabelString:[[record objectForKey:@"hour"] isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",[record objectForKey:@"hour"]]:[record objectForKey:@"hour"]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

@end
