//
//  DataParseManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "DataParseManager.h"
#import "HConstants.h"
#import "Client.h"
#import "Project.h"
#import "User.h"
#import "Record.h"
#import "AppDelegate.h"
#import "DrawerTableViewController.h"


@interface DataParseManager ()

@property (nonatomic, strong) Firebase *projects;

@end

@implementation DataParseManager

+ (DataParseManager*) sharedManager{
    static DataParseManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DataParseManager alloc]init];
        _sharedManager.projects = [FireBaseManager projectURLsharedFireBase];
    });
    return _sharedManager;
}

-(Firebase*)records{
    if (!_records) {
        _records = [FireBaseManager recordURLsharedFireBase];
    }
    return _records;
}



- (void) getAllDataFromFireBase{
    //this is where all the main action of getting clients/projects from FireBase happens after login is successful
    //We convert them into Client, Project, User objects
    [self.delegate loginSuccessful];
    [self getAllClientsAndProjectsDataFromFireBaseAndSynchronize];
    [self getUserRecords];
}

- (void) getAllClientsAndProjectsDataFromFireBaseAndSynchronize {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Get all existing clients and projects
        [self.projects observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *rawMasterClientList = snapshot.value;
                    [[NSUserDefaults standardUserDefaults] setObject:rawMasterClientList forKey:[HConstants kRawMasterClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [self saveMasterClientListInUserDefaults:rawMasterClientList];
                    [self saveCurrentUserClientListInUserDefaults:rawMasterClientList];
                    
                    //Completion Notification
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"clientsProjectsSynched"
                                                                        object:nil];
                }
                else {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants kRawMasterClientList]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants kMasterClientList]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants kCurrentUserClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                if ([self.delegate respondsToSelector:@selector(loadData)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate loadData];
                        DrawerTableViewController *dtvc = (DrawerTableViewController *) [AppDelegate globalDelegate].drawerViewController.leftViewController;
                        [dtvc loginRefresh];
                        //this makes sure that when you login, LoginViewController updates its tableview with firebase data ... with the implementation of DrawerTableViewController, there was a problem with [self.delegate loadData] not doing the job
                    });
                }
            });
        }];
    });
}

- (void) getUserRecords{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Get last 50 records by date
        [[[self.records queryOrderedByChild:[HConstants kDate]] queryLimitedToLast:50] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *records = snapshot.value;
                    __block NSMutableDictionary *sanitizedCurrentUserRecords = [[NSMutableDictionary alloc]init];
                    [records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            Record *newRecord = [[Record alloc]init];
                            newRecord.uniqueFireBaseIdentifier = (NSString*)key;
                            if ([obj objectForKey:[HConstants kClient]]) {
                                newRecord.clientName = (NSString*)[obj objectForKey:[HConstants kClient]];
                            }
                            if ([obj objectForKey:[HConstants kProject]]) {
                                newRecord.projectName = (NSString*)[obj objectForKey:[HConstants kProject]];
                            }
                            if ([obj objectForKey:[HConstants kHour]]) {
                                newRecord.hourOfTheService = (NSString*)[obj objectForKey:[HConstants kHour]];
                            }
                            if ([obj objectForKey:[HConstants kStatus]]) {
                                newRecord.statusOfUser = (NSString*)[obj objectForKey:[HConstants kStatus]];
                            }
                            
                            if ([obj objectForKey:[HConstants kType]]) {
                                newRecord.typeOfService = (NSString*)[obj objectForKey:[HConstants kType]];
                            }
                            
                            if ([obj objectForKey:[HConstants kComment]]) {
                                newRecord.commentOnService = (NSString*)[obj objectForKey:[HConstants kComment]];
                            }
                            if ([obj objectForKey:[HConstants kDate]]) {
                                newRecord.dateOfTheService = (NSString*)[obj objectForKey:[HConstants kDate]];
                                if ([sanitizedCurrentUserRecords objectForKey:newRecord.dateOfTheService]) {
                                    NSMutableArray *records = (NSMutableArray*)[sanitizedCurrentUserRecords objectForKey:newRecord.dateOfTheService];
                                    [records addObject:newRecord];
                                } else{
                                    NSMutableArray *records = [[NSMutableArray alloc]init];
                                    [records addObject:newRecord];
                                    [sanitizedCurrentUserRecords setObject:records forKey:newRecord.dateOfTheService];
                                }
                            }
                        }
                    }];
                    
                    NSData *currentUserRecordsData = [NSKeyedArchiver archivedDataWithRootObject:sanitizedCurrentUserRecords];
                    [[NSUserDefaults standardUserDefaults] setObject:currentUserRecordsData forKey:[HConstants kSanitizedCurrentUserRecords]];
                }
                else {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants kSanitizedCurrentUserRecords]];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:kStartGetUserRecordsProcessNotification object:nil];
            });
            [self.delegate userRecordsDataReceived];
        }];
    });
}





#pragma mark Refactored Methods - Custom Logic


- (void) saveMasterClientListInUserDefaults: (NSDictionary *) rawMasterClientList {
    __block NSMutableArray *masterClientList = [[NSMutableArray alloc]init];
    [rawMasterClientList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        __block Client *newClient = [[Client alloc]init];
        [newClient setClientName:(NSString*)key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objProject = (NSDictionary*)obj;
            [objProject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                __block Project *newProject = [[Project alloc]init];
                [newProject setProjectName:(NSString*)key];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *objFireBaseKey = (NSDictionary*)obj;
                    [objFireBaseKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        __block User *newUser = [[User alloc]init];
                        if ([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"name"]) {
                            [newUser setUniqueFireBaseIdentifier:(NSString*)key];
                            [newUser setUserName:(NSString*)[obj objectForKey:@"name"]];
                            [newProject addUser:newUser];
                        }
                    }];
                }
                [newClient addProject:newProject];
            }];
        }
        //Alphabetical sorting logic for master projects within a master client
        [self sortProjectsForClientByDescriptor:newClient sortDescriptor:@"projectName"];
        [masterClientList addObject:newClient];
    }];
    
    //Alphabetical sorting logic for master clients within master client list
    NSData *masterClientListData = [self getArchivedDataOfSortedArrayByDescriptor:masterClientList sortDescriptor:@"clientName"];
    [[NSUserDefaults standardUserDefaults]setObject:masterClientListData forKey:[HConstants kMasterClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) saveCurrentUserClientListInUserDefaults: (NSDictionary *) rawMasterClientList {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kCurrentUser]];
    __block NSMutableArray *currentUserClientList = [[NSMutableArray alloc]init];
    [rawMasterClientList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        __block Client *newClient = [[Client alloc]init];
        [newClient setClientName:(NSString*)key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objProject = (NSDictionary*)obj;
            [objProject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                __block Project *newProject = [[Project alloc]init];
                [newProject setProjectName:(NSString*)key];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *objFireBaseKey = (NSDictionary*)obj;
                    [objFireBaseKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        __block User *newUser = [[User alloc]init];
                        if ([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"name"] && [[obj objectForKey:@"name"]isEqualToString:username] ) {
                            [newUser setUserName:(NSString*)[obj objectForKey:@"name"]];
                            [newUser setUniqueFireBaseIdentifier:(NSString*)key];
                        } else {
                            newUser = nil;
                        }
                        if (newUser) {
                            [newProject addUser:newUser];
                        }
                    }];
                    
                }
                if (![newProject isUsersEmpty]) {
                    [newClient addProject:newProject];
                }
            }];
            //Alphabetical sorting logic for user's projects within a currenclient
            [self sortProjectsForClientByDescriptor:newClient sortDescriptor:@"projectName"];
        }
        if (![newClient isProjectsEmpty]) {
            [currentUserClientList addObject:newClient];
        }
    }];
    //Alphabetical sorting logic for clients within currentUserClients
    NSData *currentUserClientListData = [self getArchivedDataOfSortedArrayByDescriptor:currentUserClientList sortDescriptor:@"clientName"];
    [[NSUserDefaults standardUserDefaults]setObject:currentUserClientListData forKey:[HConstants kCurrentUserClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) sortProjectsForClientByDescriptor: (Client *) client sortDescriptor: (NSString *) descriptor {
    NSSortDescriptor * sortByName = [[NSSortDescriptor alloc] initWithKey:descriptor ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortByName];
    NSArray *sortedProjectsArray = [client.projects sortedArrayUsingDescriptors:sortDescriptors];
    client.projects = (NSMutableArray *)[sortedProjectsArray mutableCopy];
}

- (NSData *) getArchivedDataOfSortedArrayByDescriptor: (NSArray *) arrayToSort sortDescriptor: (NSString *) descriptor {
    NSSortDescriptor * sortByName = [[NSSortDescriptor alloc] initWithKey:descriptor ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortByName];
    NSMutableArray *sortedArray = (NSMutableArray *) [[arrayToSort sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    NSData *archivedArray = [NSKeyedArchiver archivedDataWithRootObject:sortedArray];
    return archivedArray;
}





#pragma mark Login-Related


-(void) loginSuccessful {
    [self.delegate loginSuccessful];
}

-(void) loginUnsuccessful{
    //Refer to logs - this is needed because direct tableview loading from login view controller doesn't refresh the data while communiating the drawerTableViewcontroller does work.
    [[AppDelegate globalDelegate].drawerTableViewController logOutAction];

    if ([self.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
        [self.delegate loginUnsuccessful];
    }
}

- (void) manuallySetDelegate:(id<DataParseManagerProtocol>)delegate{
    self.delegate = delegate;
}


@end

