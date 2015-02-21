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
#import "DataParseManager.h"
#import "AddClientProjectViewController.h"
#import "Client.h"
#import "Project.h"


@interface NewProjectViewController () <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *masterClientsArray;
@property (strong, nonatomic) NSMutableArray *currentUserClientsArray;
@property (strong, nonatomic) Firebase *fireBase;

@end

@implementation NewProjectViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tap on project";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[MCSwipeTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIBarButtonItem *addClientProjectButton = [[UIBarButtonItem alloc]initWithTitle:@"Add client" style:UIBarButtonItemStylePlain target:self action:@selector(pushAddClientProjectViewController)];
    self.navigationItem.rightBarButtonItem = addClientProjectButton;
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshMasterClientsArrayAndCurrentUserClientsArray];
}

- (void) refreshMasterClientsArrayAndCurrentUserClientsArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *masterClientsData = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants kMasterClientList]];
        self.masterClientsArray = [NSKeyedUnarchiver unarchiveObjectWithData:masterClientsData];
        NSLog(@"%@", self.masterClientsArray.description);
        
        NSData *currentUserClientsData = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KcurrentUserClientList]];
        self.currentUserClientsArray = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserClientsData];
        NSLog(@"%@", [self.currentUserClientsArray description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) pushAddClientProjectViewController{
    AddClientProjectViewController *addClientProjectVC = [[AddClientProjectViewController alloc]initWithNibName:@"AddClientProjectViewController" bundle:nil];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                               initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController pushViewController:addClientProjectVC animated:YES];
}




#pragma mark - Table View and Data Source Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.masterClientsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Client *client = [self.masterClientsArray objectAtIndex:section];
    return client.clientName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    Client *client = [self.masterClientsArray objectAtIndex:section];
    return [client numberOfProjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate =self;
    
    //First of all, we are creating a cell for every client and project in existence
    Client *masterClient = (Client *) [self.masterClientsArray objectAtIndex:indexPath.section];
    Project *masterProject = [masterClient projectAtIndex:indexPath.row];
    cell.textLabel.text = masterProject.projectName;
    
    //then we need to check if the current user had clients already selected. In that case, we put the checkmark
    if (self.currentUserClientsArray.count > 0) {
//        if ([masterProject.projectName isEqualToString:currentUserProject.projectName]) {
//            cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
//        } else {
//            cell.accessoryView = nil;
//        }
    }
        
    return cell;
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
    
    Client *masterClient = [self.masterClientsArray objectAtIndex:indexPath.section];
    Project *masterSelectedProject = [masterClient projectAtIndex:indexPath.row];
    
    NSLog(@"%@", masterClient);
    NSLog(@"%@", self.currentUserClientsArray[0]);
    
    if (cell.accessoryView != nil) {
        //if it already had a checkmark, then we get rid of it and delete it from firebase
        NSLog(@"current user clients array: %@", self.currentUserClientsArray.description);
        
        cell.accessoryView = nil;
        if (self.currentUserClientsArray.count > 0) {
            //this needs fix below - indexPath.section doesn't make sense here
            Client *selectedCurrentUserClient = [self.currentUserClientsArray objectAtIndex:indexPath.section];
            Project *selectedCurrentUserProject = [selectedCurrentUserClient projectAtIndex:indexPath.row];
            [self removeUserFromSelectedProject:selectedCurrentUserClient project:selectedCurrentUserProject];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Removed Project" message:[NSString stringWithFormat:@"Project %@ was removed",selectedCurrentUserProject.projectName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        return;
    }
    else {
        //if, in our local cache, we've never had the current user select this client name, then we save it on user defaults AND send to firebase
        if (![self.currentUserClientsArray containsObject:masterSelectedProject]) {
            Client *newClient = [[Client alloc]init];
            newClient.clientName = masterClient.clientName;
            [newClient.projects addObject: masterSelectedProject];
            [self.currentUserClientsArray addObject:newClient];
            NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
            [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants KcurrentUserClientList]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self sendUsernameToProjectOnFireBase: masterClient.clientName project:masterSelectedProject.projectName];
            cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
        }
        //On the contrary, if we already had the current user select this client name for a project before, check to see if particular PROJECT was selected before too and is in local cache
        else {
            Client *selectedCurrentUserClient = [self.currentUserClientsArray objectAtIndex:indexPath.section];
            if (![selectedCurrentUserClient.projects containsObject:masterSelectedProject]) {
                //our client didn't have the particular project, then we add it to local cache AND send to Firebase
                [selectedCurrentUserClient.projects addObject:masterSelectedProject];
                NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
                [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants KcurrentUserClientList]];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self sendUsernameToProjectOnFireBase: masterClient.clientName project:masterSelectedProject.projectName];
                cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
            }
        }
    }
    //2.19.2015 without hitting the data structure refreshing from loginSuccessful, we have a bug that doesn't allow you to delete right after you add something
    //By hitting loginSuccessful here, we can make sure data gets refreshed when we add, so delete works properly
    
    [[DataParseManager sharedManager] loginSuccessful];
//    [self refreshMasterClientsArrayAndCurrentUserClientsArray];
}

- (void) sendUsernameToProjectOnFireBase: (NSString *) client project: (NSString *) project{
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@",[HConstants kFireBaseURL],client,project]];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
    [[self.fireBase childByAutoId] setValue:@{@"name":username}];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New Project" message:[NSString stringWithFormat:@"%@ Added",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)removeUserFromSelectedProject: (Client *) client project: (Project *) project {
    __weak typeof(self) weakSelf = self;
    [client.projects removeObject:project];
    if ([client.projects count]== 0) {
        [self.currentUserClientsArray removeObject:client];
    }
     NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
    [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants KcurrentUserClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
    __block NSString *uniqueAddress = nil;
    NSDictionary* rawMasterClientList = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kRawMasterClientList]];
    if ([[rawMasterClientList objectForKey:client.clientName]objectForKey:project.projectName]) {
        NSDictionary* rawUserList = [[rawMasterClientList objectForKey:client.clientName]objectForKey:project.projectName];
        [rawUserList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if ([obj objectForKey:@"name"] && ([[obj objectForKey:@"name"]isEqualToString:username ])) {
                uniqueAddress = key;
                *stop = YES;
                return;
            }
        }];
        weakSelf.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/%@",[HConstants kFireBaseURL],client.clientName, project.projectName, uniqueAddress]];
        [weakSelf.fireBase removeValue];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });

}



@end
