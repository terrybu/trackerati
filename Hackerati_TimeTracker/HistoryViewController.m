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

@property (nonatomic, strong) NSMutableArray *history;

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
    __block int count = 0;
    self.history = [[NSMutableArray alloc]init];
    NSDictionary *tempDict = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUserRecords]];
    
    [tempDict enumerateKeysAndObjectsUsingBlock:^(id client, id obj, BOOL *stop){
        [self.history insertObject:[tempDict objectForKey:client] atIndex:count];
        count ++;
    }];
   
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
    return [self.history count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 143.0f;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    NSDictionary *record = [self.history objectAtIndex:indexPath.row];
    
    [cell setclientNameLabelString:[record objectForKey:@"client"]];
    [cell setprojectNameLabelString:[record objectForKey:@"project"]];
    [cell setdateLabelString:[[record objectForKey:@"date"] isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",[record objectForKey:@"date"]]:[record objectForKey:@"date"]];
    [cell sethourLabelString:[[record objectForKey:@"hour"] isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",[record objectForKey:@"hour"]]:[record objectForKey:@"hour"]];
    
    return cell;
}

@end
