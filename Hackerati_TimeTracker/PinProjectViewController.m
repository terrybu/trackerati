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
@property (strong, nonatomic) NSMutableSet *setOfCurrentUserClientNames;
@property (strong, nonatomic) NSMutableSet *setOfCurrentUserProjectNames;

@end

@implementation PinProjectViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tap to pin/unpin";
    self.navigationItem.prompt = @"Swipe left to delete entirely from database";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedSafeToRefresh) name:@"clientsProjectsSynched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableCreateButton) name:@"loginSuccess" object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[MCSwipeTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    if (![LogInManager loggedOut]) {
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
    UIBarButtonItem *addClientProjectButton = [[UIBarButtonItem alloc]initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(pushAddClientProjectViewController)];
    self.navigationItem.rightBarButtonItem = addClientProjectButton;
}

- (void) getMasterClientsArrayAndCurrentUserClientsArrayAndRefresh {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *masterClientsData = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants kMasterClientList]];
        self.masterClientsArray = [NSKeyedUnarchiver unarchiveObjectWithData:masterClientsData];
        NSData *currentUserClientsData = [[NSUserDefaults standardUserDefaults]objectForKey:[HConstants kCurrentUserClientList]];
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
    
    NSArray *masterClientNames = [self.masterClientsArray valueForKey:@"clientName"];
    addClientProjectVC.clientNames = [masterClientNames mutableCopy];
    addClientProjectVC.setOfCurrentUserProjectNames = self.setOfCurrentUserProjectNames;
    
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
    if ((self.setOfCurrentUserClientNames != nil) && ([self.setOfCurrentUserClientNames containsObject:masterClient.clientName])) {
        if ((self.setOfCurrentUserProjectNames != nil) && ([self.setOfCurrentUserProjectNames containsObject:masterProject.projectName])) {
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //this is to never let the gray cell background stay
    MCSwipeTableViewCell *cell = (MCSwipeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    Client *masterSelectedClient = [self.masterClientsArray objectAtIndex:indexPath.section];
    Project *masterSelectedProject = [masterSelectedClient projectAtIndex:indexPath.row];
    
    if (cell.accessoryView != nil) {
        //this is project/checkmark REMOVING logic
        //if project already had a checkmark, then we get rid of project and delete it from firebase
        cell.accessoryView = nil;
        [self removeUserPinFromSelectedProject:masterSelectedClient project:masterSelectedProject];
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
            [self.setOfCurrentUserClientNames addObject:newClient.clientName];
            [self.setOfCurrentUserProjectNames addObject:masterSelectedProject.projectName];
            NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
            [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants kCurrentUserClientList]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self pinUserToProjectOnFireBase: masterSelectedClient.clientName project:masterSelectedProject.projectName];
        }
        //On the contrary, if we already had the current user select this client name for a project before, check to see if particular PROJECT was selected before too and is in local cache
        else {
            Client *selectedCurrentUserClient = [self.currentUserClientsArray objectAtIndex:indexPath.section];
            if (![selectedCurrentUserClient.projects containsObject:masterSelectedProject]) {
                //our client didn't have the particular project, then we add it to local cache AND send to Firebase
                [selectedCurrentUserClient.projects addObject:masterSelectedProject];
                [self.setOfCurrentUserClientNames addObject:selectedCurrentUserClient.clientName];
                [self.setOfCurrentUserProjectNames addObject:masterSelectedProject.projectName];
                NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
                [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants kCurrentUserClientList]];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self pinUserToProjectOnFireBase: masterSelectedClient.clientName project:masterSelectedProject.projectName];
            }
        }
        cell.accessoryView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
        [self.tableView reloadData];
    }
    //2.19.2015 without refreshing data here, we have a bug that doesn't allow you to delete right after you add something
    //By hitting DataParseManager here, we can make sure data gets refreshed when we add, so delete works properly
    [[DataParseManager sharedManager] getAllDataFromFireBaseAfterLoginSuccess];
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


#pragma mark Custom Logic For Pinning/Removing user from project based on Cell Selection
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

- (void) pinUserToProjectOnFireBase: (NSString *) client project: (NSString *) project{
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@",[HConstants kFireBaseURL],client,project]];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kCurrentUser]];
    [[self.fireBase childByAutoId] setValue:@{@"name":username}];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New Project" message:[NSString stringWithFormat:@"%@ Added",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)removeUserPinFromSelectedProject: (Client *) masterClient project: (Project *) masterProject {
    __weak typeof(self) weakSelf = self;
    Client *client = [self findCorrespondingClientInCurrentUserClientList:masterClient];
    Project *project = [self findCorrespondingProjectFromCorrespondingClient:client masterProject:masterProject];
    
    [client.projects removeObject:project];
    [self.setOfCurrentUserProjectNames removeObject:project.projectName];
    
    if ([client.projects count]== 0) {
        [self.currentUserClientsArray removeObject:client];
        [self.setOfCurrentUserClientNames removeObject:client.clientName];
    }
     NSData *currentUserClientListData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUserClientsArray];
    [[NSUserDefaults standardUserDefaults] setObject:currentUserClientListData forKey:[HConstants kCurrentUserClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });

}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
