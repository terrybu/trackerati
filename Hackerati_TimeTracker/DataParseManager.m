//
//  DataParseManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "DataParseManager.h"
#import "FireBaseManager.h"
#import "HConstants.h"
#import "Client.h"
#import "Project.h"
#import "User.h"
#import "Record.h"

@interface DataParseManager ()

@property (nonatomic, strong) Firebase *projects;
@property (nonatomic, strong) Firebase *records;

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

//this is where all the main action of getting clients/projects from FireBase happens after login is successful
//We convert them into Client, Project, User objects

- (void) getAllDataFromFireBaseAfterLoginSuccess{
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
                
                    if ([self.delegate respondsToSelector:@selector(loadData)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate loadData];
                        });
                    }
                }
                else {
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants kRawMasterClientList]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants kMasterClientList]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants KcurrentUserClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    if ([self.delegate respondsToSelector:@selector(loadData)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate loadData];
                        });
                    }
                }
            });
        }];
        [self getUserRecords];
    });
}

- (void) saveMasterClientListInUserDefaults: (NSDictionary *) rawMasterClientList {
    
    //debug
//    NSLog(rawMasterClientList.description);
    
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
        //Alphabetical sorting logic for projects within a client
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"projectName" ascending:YES]];
        NSArray *sortedProjectsArray = [newClient.projects sortedArrayUsingDescriptors:sortDescriptors];
        newClient.projects = (NSMutableArray *) [sortedProjectsArray mutableCopy];
        [masterClientList addObject:newClient];
    }];
    
    //Alphabetical sorting logic for clients within master client list
    NSData *masterClientListData = [self returnArchivedDataOfSortedArrayByDescriptor:masterClientList sortDescriptor:@"clientName"];
    [[NSUserDefaults standardUserDefaults]setObject:masterClientListData forKey:[HConstants kMasterClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) saveCurrentUserClientListInUserDefaults: (NSDictionary *) rawMasterClientList {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
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
            //Alphabetical sorting logic for projects within a client
            NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"projectName" ascending:YES]];
            NSArray *sortedProjectsArray = [newClient.projects sortedArrayUsingDescriptors:sortDescriptors];
            newClient.projects = (NSMutableArray *)[sortedProjectsArray mutableCopy];
        }
        if (![newClient isProjectsEmpty]) {
            [currentUserClientList addObject:newClient];
        }
    }];
    //Alphabetical sorting logic for clients within currentUserClient
    NSData *currentUserClientListData = [self returnArchivedDataOfSortedArrayByDescriptor:currentUserClientList sortDescriptor:@"clientName"];
    [[NSUserDefaults standardUserDefaults]setObject:currentUserClientListData forKey:[HConstants KcurrentUserClientList]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSData *) returnArchivedDataOfSortedArrayByDescriptor: (NSArray *) arrayToSort sortDescriptor: (NSString *) descriptor {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:descriptor ascending:YES]];
    NSMutableArray *sortedArray = (NSMutableArray *) [[arrayToSort sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    NSData *archivedArray = [NSKeyedArchiver archivedDataWithRootObject:sortedArray];
    return archivedArray;
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
                    NSData *sanitizedCurrentUserRecordsData = [NSKeyedArchiver archivedDataWithRootObject:sanitizedCurrentUserRecords];
                    [[NSUserDefaults standardUserDefaults] setObject:sanitizedCurrentUserRecordsData forKey:[HConstants KSanitizedCurrentUserRecords]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kStartGetUserRecordsProcessNotification object:nil];
                }
                else {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants KSanitizedCurrentUserRecords]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kStartGetUserRecordsProcessNotification object:nil];
                }
            });
            [self.delegate userRecordsDataReceived];
        }];
    });
}

-(void) loginUnsuccessful{
    if ([self.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
        [self.delegate loginUnsuccessful];
    }
}

- (void) manuallySetDelegate:(id<DataParseManagerProtocol>)delegate{
    self.delegate = delegate;
}

-(Firebase*)records{
    if (!_records) {
        _records = [FireBaseManager recordURLsharedFireBase];
    }
    return _records;
}

@end

