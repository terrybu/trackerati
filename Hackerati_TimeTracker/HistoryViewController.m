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

@property (nonatomic, strong) NSMutableArray* sortedDateKeys;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *currentUserRecordsData = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
        self.recordsHistoryDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserRecordsData];
        if (self.recordsHistoryDictionary.count > 0)
            self.sortedDateKeys = [self returnSortedDateStringKeysArray:[self.recordsHistoryDictionary allKeys]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    if (![DataParseManager loggedOut]) {
        NSLog(@"logged in as %@, reporting from history vc", [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[DataParseManager sharedManager] getUserRecords];
            if (self.recordsHistoryDictionary.count > 0)
                self.sortedDateKeys = [self returnSortedDateStringKeysArray:[self.recordsHistoryDictionary allKeys]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    else { //if logged out don't do anything, hide logout button
        NSLog(@"logged out, reporting from history vc");
        self.navigationItem.rightBarButtonItem = nil;
        [self.tableView reloadData];
    }
}

- (void)logOutAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartLogOutProcessNotification object:nil];
    [DataParseManager setLoggedOut:YES];
    [DataParseManager sharedManager].records = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Record TableView Cell Delegate
-(void)didClickDetailButton:(NSIndexPath*)indexPath{
    self.recordDetailViewController =[[RecordDetailViewController alloc]initWithNibName:@"RecordDetailViewController" bundle:nil];
    self.recordDetailViewController.record = [((NSArray*)[self.recordsHistoryDictionary objectForKey:[self.sortedDateKeys objectAtIndex:indexPath.section]])objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.recordDetailViewController animated:YES];
}


#pragma mark - Table View and Data Source Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sortedDateKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *records = [self.recordsHistoryDictionary objectForKey:[self.sortedDateKeys objectAtIndex:section]];
    return records.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sortedDateKeys objectAtIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSMutableArray *records = [self.recordsHistoryDictionary objectForKey:[self.sortedDateKeys objectAtIndex:indexPath.section]];
    
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


#pragma mark - Custom logic
- (NSMutableArray *) returnSortedDateStringKeysArray: (NSArray *) unsortedDateStringsArray {
    NSMutableArray *unsortedDateObjectsArray = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    for (NSString *dateStr in unsortedDateStringsArray) {
        // Convert string to date object
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        [unsortedDateObjectsArray addObject:date];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:FALSE];
    [unsortedDateObjectsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableArray *sortedDateStringsArray = [[NSMutableArray alloc]init];
    for (NSDate *date in unsortedDateObjectsArray) {
        // Convert date object to desired output format
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        [sortedDateStringsArray addObject:[dateFormat stringFromDate:date]];
    }
    return sortedDateStringsArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
