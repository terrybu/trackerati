//
//  PinProjectViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/7/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "PinProjectViewController.h"
#import "HConstants.h"
#import <MCSwipeTableViewCell.h>
#import <Firebase/Firebase.h>
#import "DataParseManager.h"
#import "AddClientProjectViewController.h"
#import "Client.h"
#import "Project.h"


@interface PinProjectViewController () <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate> {
    Client *clientToDelete;
    Project *projectToDelete;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Firebase *fireBase;
@property (strong, nonatomic) NSMutableArray *masterClientsArray;
@property (strong, nonatomic) NSMutableArray *currentUserClientsArray;

@property (strong, nonatomic) NSMutableDictionary *pinnedDictionary;


@end

@implementation PinProjectViewController

static NSString *CellIdentifier = @"Cell";

- (NSMutableDictionary *) pinnedDictionary {
    if (_pinnedDictionary == nil)
        _pinnedDictionary = [[NSMutableDictionary alloc]init];
    
    return _pinnedDictionary;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tap to pin/unpin";
    self.navigationItem.prompt = @"Swipe left to delete entirely from database";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedSafeToRefresh) name:@"clientsProjectsSynched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableCreateButton) name:@"loginSuccess" object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[MCSwipeTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    if (![LoginManager loggedOut]) {
        [self enableCreateButton];
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMasterClientsArrayAndCurrentUserClientsArrayAndRefresh];
}

- (void) dataReceivedSafeToRefresh {
    [self getMasterClientsArrayAndCurrentUserClientsArrayAndRefresh];
}

- (void) enableCreateButton {
    UIBarButtonItem *addClientProjectButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushAddClientProjectViewController)];
    self.navigationItem.rightBarButtonItem = addClientProjectButton;
}

- (void) getMasterClientsArrayAndCurrentUserClientsArrayAndRefresh {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *masterClientsData = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants kMasterClientList]];
        self.masterClientsArray = [NSKeyedUnarchiver unarchiveObjectWithData:masterClientsData];
        NSData *currentUserClientsData = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants kCurrentUserClientList]];
        self.currentUserClientsArray = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserClientsData];
        
        //I need a dictionary of current user clients and their projects
        //key is client name in string
        //value is a NSMutableArray of all the current pinned projects
        //I don't want to use array because we will be doing too much iterating O(n)
        
        for (Client *client in self.currentUserClientsArray) {
            NSArray *arrayOfProjectNames = [client.projects valueForKey:@"projectName"];
            NSMutableArray *mutableArrayOfProjectNames = [arrayOfProjectNames mutableCopy];
            [self.pinnedDictionary setObject:mutableArrayOfProjectNames forKey:client.clientName];
        }
        
        NSLog(self.pinnedDictionary.description);
        
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
    
    NSArray *masterClientNames = [self.masterClientsArray valueForKey:@"clientName"];
    addClientProjectVC.clientNames = [masterClientNames mutableCopy];
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                               initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    [self.navigationController pushViewController:addClientProjectVC animated:NO];
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
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate =self;
    
    //Create a cell for every project in existence, sectioned by client name
    Client *masterClient = (Client *) [self.masterClientsArray objectAtIndex:indexPath.section];
    Project *masterProject = [masterClient projectAtIndex:indexPath.row];
    cell.textLabel.text = masterProject.projectName;
    
    //Checkmark addition logic
    //we loop over these sets to find if this particular project was indeed selected by current user in the past
    cell.accessoryView = nil;
    if ((self.pinnedDictionary != nil) && ([self.pinnedDictionary valueForKey:masterClient.clientName])) {
        if ([[self.pinnedDictionary valueForKey:masterClient.clientName] containsObject:masterProject.projectName]) {
            cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
        }
    }
    
    UIImageView *eraseMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Erase.png"]];
    [cell setSwipeGestureWithView:eraseMark color:[UIColor whiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:nil];
    [cell setSwipeGestureWithView:eraseMark color:[UIColor whiteColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        //Swipe Left To Remove Project altogether from server
        clientToDelete = masterClient;
        projectToDelete = masterProject;
        [self removeProjectAfterConfirmationAlert:masterProject client: masterClient];
    }];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MCSwipeTableViewCell *cell = (MCSwipeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    Client *masterSelectedClient = [self.masterClientsArray objectAtIndex:indexPath.section];
    Project *masterSelectedProject = [masterSelectedClient projectAtIndex:indexPath.row];
    
    if ([self.pinnedDictionary objectForKey:masterSelectedClient.clientName] && [[self.pinnedDictionary valueForKey:masterSelectedClient.clientName] containsObject: masterSelectedProject.projectName]) {
        //this is pin REMOVING logic
        [self removeUserPinFromSelectedProject:masterSelectedClient project:masterSelectedProject];
        cell.accessoryView = nil;

//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Removed Project" message:[NSString stringWithFormat:@"%@ was unpinned from your projects", masterSelectedProject.projectName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
        return;
    }
    else {
        //this is pin ADDING logic
        //if, in our local cache, we've never had the current user pin this client name before, then we pin the whole client, and the project
        NSMutableArray *pinnedProjectNames = [self.pinnedDictionary objectForKey:masterSelectedClient.clientName];
        if (pinnedProjectNames == nil) {
            Client *newClient = [[Client alloc]init];
            newClient.clientName = masterSelectedClient.clientName;
            newClient.projects = [[NSMutableArray alloc]init];
            [newClient.projects addObject: masterSelectedProject];
            [self.currentUserClientsArray addObject:newClient];
            [self.pinnedDictionary setValue:[[newClient.projects valueForKey:@"projectName"]mutableCopy] forKey:newClient.clientName];
        }
        else {
            //On the contrary, if we already had the current user pin this client name for a project before, check to see if particular PROJECT was pinned
            Client *selectedCurrentUserClient = [self findCorrespondingClientInCurrentUserClientList:masterSelectedClient];
            if (![pinnedProjectNames containsObject:masterSelectedProject.projectName]) {
                //our client didn't have the particular project, then we add it to local cache
                [selectedCurrentUserClient.projects addObject:masterSelectedProject];
                [pinnedProjectNames addObject:masterSelectedProject.projectName];
            }
        }
        [self cacheCurrentUserClients];
        [self pinUserToProjectOnFireBase: masterSelectedClient.clientName project:masterSelectedProject.projectName];
        cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
    }
}



#pragma mark Custom Logic For Pinning/Removing user from project based on Cell Selection
- (void)cacheCurrentUserClients {
    NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
    [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants kCurrentUserClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) pinUserToProjectOnFireBase: (NSString *) client project: (NSString *) project{
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@",[HConstants kFireBaseURL],client,project]];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kCurrentUser]];
    [[self.fireBase childByAutoId] setValue:@{@"name":username}];
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New Project" message:[NSString stringWithFormat:@"%@ Added",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alertView show];
}


-(void)removeUserPinFromSelectedProject: (Client *) masterClient project: (Project *) masterProject {
    Client *client = [self findCorrespondingClientInCurrentUserClientList:masterClient];
    Project *project = [self findCorrespondingProjectFromCorrespondingClient:client masterProject:masterProject];
    if (project != nil) {
        [client.projects removeObject:project];
    }
    if (client != nil && [client.projects count]== 0) {
        [self.currentUserClientsArray removeObject:client];
        [self.pinnedDictionary removeObjectForKey:client.clientName];
    }
    [self cacheCurrentUserClients];
    [[self.pinnedDictionary objectForKey:client.clientName]removeObjectIdenticalTo:project.projectName];
    
    [self removePinFromFireBase:project client:client];
    [self.tableView reloadData];
}

- (void)removePinFromFireBase:(Project *)project client:(Client *)client {
    __weak typeof(self) weakSelf = self;
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kCurrentUser]];
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
}

- (Client *) findCorrespondingClientInCurrentUserClientList: (Client *) masterClient {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientName contains[c] %@", masterClient.clientName];
    NSArray *resultArray = [self.currentUserClientsArray filteredArrayUsingPredicate:predicate];
    if (resultArray == nil || [resultArray count] == 0)
        return nil;
    return resultArray[0];
}

- (Project *) findCorrespondingProjectFromCorrespondingClient: (Client *) correspondingClient masterProject: (Project *) masterProject{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectName contains[c] %@", masterProject.projectName];
    NSArray *resultArray = [correspondingClient.projects filteredArrayUsingPredicate:predicate];
    if (resultArray == nil || [resultArray count] == 0)
        return nil;
    return resultArray[0];
}

#pragma mark Swipe Cell - Removing Project from Firebase Logic
- (void) removeProjectAfterConfirmationAlert: (Project *) project client: (Client *) client {
    UIAlertView *alertView;
    if (client.projects.count == 1) {
        alertView = [[UIAlertView alloc]initWithTitle:@"Warning" message:[NSString stringWithFormat:@"Are you sure you want to delete project named %@ permanently from the database? This will also delete client named %@.", project.projectName, client.clientName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Yes", nil];
    }
    else {
        alertView = [[UIAlertView alloc]initWithTitle:@"Warning" message:[NSString stringWithFormat:@"Are you sure you want to delete project named %@ permanently from the database? This will also affect other users listed on the project.", project.projectName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Yes", nil];
    }
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    __weak typeof(self) weakSelf = self;
    
    if ([buttonTitle isEqualToString:@"Yes"]) {
        //Delete Logic
        self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/",[HConstants kFireBaseURL], clientToDelete.clientName, projectToDelete.projectName]];
        [self.fireBase removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            if (!error) {
                // Delete worked on Firebase - delete on local cache
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    Client *currentUsersClientCorresponding = [self findCorrespondingClientInCurrentUserClientList:clientToDelete];
                    Project *correspondingProject = [self findCorrespondingProjectFromCorrespondingClient:currentUsersClientCorresponding masterProject:projectToDelete];
                    [currentUsersClientCorresponding.projects removeObject:correspondingProject];
                    if (currentUsersClientCorresponding.projects.count == 0)
                        [self.currentUserClientsArray removeObject:currentUsersClientCorresponding];
                    NSData *currentClientsData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
                    [[NSUserDefaults standardUserDefaults]setObject:currentClientsData forKey:[HConstants kCurrentUserClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    [clientToDelete.projects removeObject:projectToDelete];
                    if (clientToDelete.projects.count == 0)
                        [self.masterClientsArray removeObject:clientToDelete];
                    NSData *masterClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.masterClientsArray];
                    [[NSUserDefaults standardUserDefaults]setObject:masterClientListData forKey:[HConstants kMasterClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                });
            }
            else {
                // cache for later, or notify user that there was an error and they should try again.
                NSLog(@"delete was not successful on firebase due to errors: %@", error);
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Deletion Not Successful" message:[NSString stringWithFormat:@"Something went wrong, deletion not complete on server for project %@", projectToDelete.projectName] delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
                [alertView show];
            }
        }];
    }
    else {
        [self.tableView reloadData];
    }
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
