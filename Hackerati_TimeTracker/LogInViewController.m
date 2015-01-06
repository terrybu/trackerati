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

@interface LogInViewController () 

@property (strong, nonatomic) NSMutableDictionary *sectionInformation;
@property (strong, nonatomic) NSMutableDictionary *rowInformation;
@property (strong, nonatomic) GPPSignIn *googleSignIn;
@property (strong, nonatomic) HistoryViewController *historyViewController;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Clients";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(historyAction:)];
    self.sectionInformation = [[NSMutableDictionary alloc]init];
    self.rowInformation = [[NSMutableDictionary alloc]init];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:section]];
    return [rows count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    cell.textLabel.text = [rows objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.rowInformation allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return (NSString*)[self.rowInformation objectForKey:[NSNumber numberWithInteger:section]];
}

@end
