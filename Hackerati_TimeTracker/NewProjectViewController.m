//
//  NewProjectViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/7/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "NewProjectViewController.h"
#import "HConstants.h"
#import <MCSwipeTableViewCell.h>
#import <Firebase/Firebase.h>
#import "DataParser.h"
#import "AddClientProjectViewController.h"


@interface NewProjectViewController () <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary *datas;
@property (strong, nonatomic) NSMutableDictionary *sectionInformation;
@property (strong, nonatomic) NSMutableDictionary *rowInformation;
@property (strong, nonatomic) Firebase *fireBase;

@end

@implementation NewProjectViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tap on project";
    self.sectionInformation = [[NSMutableDictionary alloc]init];
    self.rowInformation = [[NSMutableDictionary alloc]init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[MCSwipeTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIBarButtonItem *addClientProjectButton = [[UIBarButtonItem alloc]initWithTitle:@"Add client" style:UIBarButtonItemStylePlain target:self action:@selector(pushAddClientProjectViewController)];
    self.navigationItem.rightBarButtonItem = addClientProjectButton;
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.datas = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kMasterClientList]];
        __block int count = 0;
        __weak typeof(self) weakSelf = self;
        [self.datas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            [weakSelf.sectionInformation setObject:key forKey:[NSNumber numberWithInt:count]];
            [weakSelf.rowInformation setObject:obj forKey:[NSNumber numberWithInt:count]];
            count++;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) pushAddClientProjectViewController{
    AddClientProjectViewController *addClientProjectVC = [[AddClientProjectViewController alloc]initWithNibName:@"AddClientProjectViewController" bundle:nil];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                               initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController pushViewController:addClientProjectVC animated:YES];
}




#pragma mark - Table View and Data Source Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *rows = [self.rowInformation objectForKey:[NSNumber numberWithInteger:section]];
    return [rows count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate =self;
    
    NSDictionary* currentUserData = (NSDictionary*)[[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KcurrentUserClientList]];
    NSString*client = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    NSArray *rows = [self.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    cell.textLabel.text = [rows objectAtIndex:indexPath.row];
    if ([currentUserData objectForKey:client] && [((NSArray*)[currentUserData objectForKey:client]) containsObject:(NSString*) [rows objectAtIndex:indexPath.row]]) {
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
    } else {
        cell.accessoryView = nil;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.sectionInformation allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return (NSString*)[self.sectionInformation objectForKey:[NSNumber numberWithInteger:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //this is to never let the gray cell background stay
    MCSwipeTableViewCell *cell = (MCSwipeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary* data = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KcurrentUserClientList]];
    NSMutableDictionary *mutableData = [[NSMutableDictionary alloc]initWithDictionary:data];
    NSString *client = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    NSArray *rows = [self.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    NSString *project = [rows objectAtIndex:indexPath.row];
    
    if (cell.accessoryView != nil) {
        //if it already had a checkmark, then we get rid of it and delete it from firebase
        cell.accessoryView = nil;
        [self removeUserFromSelectedProject:mutableData client:client project:project];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Removed Project" message:[NSString stringWithFormat:@"Project %@ was removed",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    else {
        //if, in our local cache, we never had the current user use this client name, then we set it
        if (![mutableData objectForKey:client]) {
            [mutableData setObject:[[NSMutableArray alloc]initWithObjects:project,nil] forKey:client];
            [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:[HConstants KcurrentUserClientList]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self sendUsernameToProjectOnFireBase: client project:project];
            cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
        }
        //On the contrary, if, in our local cache, we already had the current user use this client name for a project, check to see if particular project is in local cache
        else {
            NSMutableArray *projects = [mutableData objectForKey:client];
            if (![projects containsObject:project]) {
                //if not, then we add it to local cache AND send to Firebase
                NSMutableArray *mutableProjects = [[NSMutableArray alloc]initWithArray:projects];
                [mutableProjects addObject:project];
                [mutableData setObject:mutableProjects forKey:client];
                [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:[HConstants KcurrentUserClientList]];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self sendUsernameToProjectOnFireBase: client project:project];
                cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
            }
        }
        [[DataParser sharedManager] loginSuccessful];
        //2.19.2015 without hitting the data structure refreshing from loginSuccessful, we have a bug that doesn't allow you to delete right after you add something
        //By hitting loginSuccessful here, we can make sure data gets refreshed when we add, so delete works properly
        [self.tableView reloadData];
    }
}

- (void) sendUsernameToProjectOnFireBase: (NSString *) client project: (NSString *) project{
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@",[HConstants kFireBaseURL],client,project]];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
    [[self.fireBase childByAutoId] setValue:@{@"name":username}];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New Project" message:[NSString stringWithFormat:@"%@ Added",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}



-(void)removeUserFromSelectedProject: (NSMutableDictionary*) mutableData client: (NSString *) client project: (NSString *) project {
    __weak typeof(self) weakSelf = self;
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
        weakSelf.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/%@",[HConstants kFireBaseURL],client,project,uniqueAddress]];
        [weakSelf.fireBase removeValue];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });

}



@end
