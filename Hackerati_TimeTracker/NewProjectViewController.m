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
@property (strong, nonatomic) NSMutableSet *setOfCurrentUserClientNames;;
@property (strong, nonatomic) NSMutableSet *setOfCurrentUserProjectNames;

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
        NSData *currentUserClientsData = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants KcurrentUserClientList]];
        self.currentUserClientsArray = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserClientsData];
        self.setOfCurrentUserClientNames = [NSMutableSet setWithArray:[self.currentUserClientsArray valueForKey:@"clientName"]];
        self.setOfCurrentUserProjectNames = [[NSMutableSet alloc]init];
        for (Client *client in self.currentUserClientsArray) {
            NSArray *arrayOfProjectNamesOfClient = [client.projects valueForKey:@"projectName"];
            [self.setOfCurrentUserProjectNames addObjectsFromArray:arrayOfProjectNamesOfClient];
        }
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
    
    //Create a cell for every project in existence, sectioned by client name
    Client *masterClient = (Client *) [self.masterClientsArray objectAtIndex:indexPath.section];
    Project *masterProject = [masterClient projectAtIndex:indexPath.row];
    cell.textLabel.text = masterProject.projectName;
    
    if ((self.setOfCurrentUserClientNames != nil) && ([self.setOfCurrentUserClientNames containsObject:masterClient.clientName])) {
        if ((self.setOfCurrentUserProjectNames != nil) && ([self.setOfCurrentUserProjectNames containsObject:masterProject.projectName])) {
            cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
        }
    }
    else
        cell.accessoryView = nil;
    
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
    
    Client *masterSelectedClient = [self.masterClientsArray objectAtIndex:indexPath.section];
    Project *masterSelectedProject = [masterSelectedClient projectAtIndex:indexPath.row];
    
    if (cell.accessoryView != nil) {
        //this is project/checkmark REMOVING logic
        //if project already had a checkmark, then we get rid of project and delete it from firebase
        cell.accessoryView = nil;
        [self removeUserFromSelectedProject:masterSelectedClient project:masterSelectedProject];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Removed Project" message:[NSString stringWithFormat:@"Project %@ was removed", masterSelectedProject.projectName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return;
    }
    else {
        //this is project/checkmark ADDING logic
        
        //if, in our local cache, we've never had the current user select this client name, then we save it on user defaults AND send to firebase
        if (![self.currentUserClientsArray containsObject:masterSelectedProject]) {
            Client *newClient = [[Client alloc]init];
            newClient.clientName = masterSelectedClient.clientName;
            [newClient.projects addObject: masterSelectedProject];
            [self.currentUserClientsArray addObject:newClient];
            NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
            [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants KcurrentUserClientList]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self sendUsernameToProjectOnFireBase: masterSelectedClient.clientName project:masterSelectedProject.projectName];
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
                [self sendUsernameToProjectOnFireBase: masterSelectedClient.clientName project:masterSelectedProject.projectName];
                cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
            }
        }

        
    }
    //2.19.2015 without refreshing data here, we have a bug that doesn't allow you to delete right after you add something
    //By hitting DataParseManager here, we can make sure data gets refreshed when we add, so delete works properly
    [[DataParseManager sharedManager] getAllDataFromFireBaseAfterLoginSuccess];
}

- (Client *) findCorrespondingClientInCurrentUserClientList: (Client *) masterClient {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientName contains[c] %@", masterClient.clientName];
    NSArray *filtered = [self.currentUserClientsArray filteredArrayUsingPredicate:predicate];
    NSLog(@"the one found from doing predicate filter of currentuserarray: %@", filtered[0]);
    NSLog(@"all the current user clients array: %@", self.currentUserClientsArray.description);
    return filtered[0];
}

- (Project *) findCorrespondingProjectFromCorrespondingClient: (Client *) correspondingClient masterProject: (Project *) masterProject{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectName contains[c] %@", masterProject.projectName];
    return [correspondingClient.projects filteredArrayUsingPredicate:predicate][0];
}

- (void) sendUsernameToProjectOnFireBase: (NSString *) client project: (NSString *) project{
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@",[HConstants kFireBaseURL],client,project]];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
    [[self.fireBase childByAutoId] setValue:@{@"name":username}];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New Project" message:[NSString stringWithFormat:@"%@ Added",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)removeUserFromSelectedProject: (Client *) masterClient project: (Project *) masterProject {
    __weak typeof(self) weakSelf = self;
    Client *client = [self findCorrespondingClientInCurrentUserClientList:masterClient];
    NSLog(@"client from remove method %@", client);
    Project *project = [self findCorrespondingProjectFromCorrespondingClient:client masterProject:masterProject];
    [client.projects removeObject:project];
    
    //we also remove from set of names
    [self.setOfCurrentUserProjectNames removeObject:project.projectName];
    
    if ([client.projects count]== 0) {
        [self.currentUserClientsArray removeObject:client];
        [self.setOfCurrentUserClientNames removeObject:client.clientName];
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
