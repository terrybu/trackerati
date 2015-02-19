//
//  DataParser.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "DataParser.h"
#import "FireBaseManager.h"
#import "HConstants.h"
#import "LogInManager.h"

@interface DataParser ()

@property (nonatomic, strong) Firebase *projects;
@property (nonatomic, strong) Firebase *records;

@end

@implementation DataParser

+ (DataParser*) sharedManager{
    static DataParser *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DataParser alloc]init];
        _sharedManager.projects = [FireBaseManager projectURLsharedFireBase];
    });
    return _sharedManager;
}

- (void) loginSuccessful{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Get all existing clients and projects
        [self.projects observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *rawMasterClientList = snapshot.value;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:rawMasterClientList forKey:[HConstants kRawMasterClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    __block NSMutableDictionary *masterClientList = [[NSMutableDictionary alloc]init];
                    
                    [rawMasterClientList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        NSDictionary *projectDictionary = (NSDictionary*) obj;
                        NSArray *projectsArray = [projectDictionary allKeys];
                        [masterClientList setObject:projectsArray forKey:key];
                    }];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:masterClientList forKey:[HConstants kMasterClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
                    __block NSMutableDictionary *tempCurrentUserClientList = [[NSMutableDictionary alloc]init];
                    
                    [rawMasterClientList enumerateKeysAndObjectsUsingBlock:^(id client, id obj, BOOL *stop){
                        __block NSMutableDictionary *tempMut = [[NSMutableDictionary alloc]init];
                        [obj enumerateKeysAndObjectsUsingBlock:^(id project, id obj, BOOL *stop){
                            __block NSMutableArray *names = [[NSMutableArray alloc]init];
                            [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                                NSDictionary *personDictionary = (NSDictionary*)obj;
                                NSString *personString =[personDictionary objectForKey:@"name"];
                                [names addObject:personString];
                            }];
                            [tempMut setObject:names forKey:project];
                        }];
                        [tempCurrentUserClientList setObject:tempMut forKey:client];
                    }];
                    
                    [tempCurrentUserClientList enumerateKeysAndObjectsUsingBlock:^(id client, id obj, BOOL *stop){
                        [obj enumerateKeysAndObjectsUsingBlock:^(id project, id obj, BOOL *stop){
                            NSArray *people = (NSArray*)obj;
                            if (![people containsObject:username]) {
                                [[tempCurrentUserClientList objectForKey:client] removeObjectForKey:project];
                                if ( [((NSDictionary*)[tempCurrentUserClientList objectForKey:client]) count] == 0 ) {
                                    [tempCurrentUserClientList removeObjectForKey:client];
                                }
                            }
                        }];
                    }];
                    
                    __block NSMutableDictionary *currentUserClientList = [[NSMutableDictionary alloc]init];
                    [tempCurrentUserClientList enumerateKeysAndObjectsUsingBlock:^(id client, id obj, BOOL *stop){
                        NSDictionary *projects = (NSDictionary*)obj;
                        NSArray *tempArray = [projects allKeys];
                        [currentUserClientList setObject:[[NSMutableArray alloc]initWithArray:tempArray] forKey:client];
                    }];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:currentUserClientList forKey:[HConstants KcurrentUserClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
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

- (void) getUserRecords{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Get last 50 records by date
        [[[self.records queryOrderedByChild:[HConstants kDate]] queryLimitedToLast:50] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *records = snapshot.value;
                    
                    __block NSMutableDictionary *sanitizedCurrentUserRecords = [[NSMutableDictionary alloc]init];
                    [records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([obj objectForKey:[HConstants kClient]] && [obj objectForKey:[HConstants kProject]] && [obj objectForKey:[HConstants kDate]] && [obj objectForKey:[HConstants kHour]] && [obj objectForKey:[HConstants kStatus]] && [obj objectForKey:[HConstants kType]]) {
                            if ([sanitizedCurrentUserRecords objectForKey:[obj objectForKey:[HConstants kDate]]] ) {
                                NSMutableArray *records = [sanitizedCurrentUserRecords objectForKey:[obj objectForKey:[HConstants kDate]]];
                                if ([obj objectForKey:[HConstants kComment]]) {
                                    [records addObject:@{[HConstants kClient]:[obj objectForKey:[HConstants kClient]],[HConstants kProject]:[obj objectForKey:[HConstants kProject]],[HConstants kHour]:[obj objectForKey:[HConstants kHour]],[HConstants kComment]:[obj objectForKey:[HConstants kComment]],@"key":(NSString*)key,[HConstants kDate]:[obj objectForKey:[HConstants kDate]],[HConstants kStatus]:[obj objectForKey:[HConstants kStatus]],[HConstants kType]:[obj objectForKey:[HConstants kType]]}];
                                } else{
                                    [records addObject:@{[HConstants kClient]:[obj objectForKey:[HConstants kClient]],[HConstants kProject]:[obj objectForKey:[HConstants kProject]],[HConstants kHour]:[obj objectForKey:[HConstants kHour]],@"key":(NSString*)key,[HConstants kDate]:[obj objectForKey:[HConstants kDate]],[HConstants kStatus]:[obj objectForKey:[HConstants kStatus]],[HConstants kType]:[obj objectForKey:[HConstants kType]]}];
                                }
                                [sanitizedCurrentUserRecords setObject:records forKey:[obj objectForKey:[HConstants kDate]]];
                            } else{
                                NSMutableArray *records = nil;
                                if ([obj objectForKey:[HConstants kComment]]) {
                                    records = [[NSMutableArray alloc]initWithObjects:@{[HConstants kClient]:[obj objectForKey:[HConstants kClient]],[HConstants kProject]:[obj objectForKey:[HConstants kProject]],[HConstants kHour]:[obj objectForKey:[HConstants kHour]],[HConstants kComment]:[obj objectForKey:[HConstants kComment]],@"key":(NSString*)key,[HConstants kDate]:[obj objectForKey:[HConstants kDate]],[HConstants kStatus]:[obj objectForKey:[HConstants kStatus]],[HConstants kType]:[obj objectForKey:[HConstants kType]]}, nil];
                                } else{
                                    records = [[NSMutableArray alloc]initWithObjects:@{[HConstants kClient]:[obj objectForKey:[HConstants kClient]],[HConstants kProject]:[obj objectForKey:[HConstants kProject]],[HConstants kHour]:[obj objectForKey:[HConstants kHour]],@"key":(NSString*)key,[HConstants kDate]:[obj objectForKey:[HConstants kDate]],[HConstants kStatus]:[obj objectForKey:[HConstants kStatus]],[HConstants kType]:[obj objectForKey:[HConstants kType]]}, nil];
                                }
                                [sanitizedCurrentUserRecords setObject:records forKey:[obj objectForKey:[HConstants kDate]]];
                            }
                        }
                    }];
                    [[NSUserDefaults standardUserDefaults] setObject:sanitizedCurrentUserRecords forKey:[HConstants KSanitizedCurrentUserRecords]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSArray *keys = [sanitizedCurrentUserRecords allKeys];
                    NSArray *sanitizedCurrentUserRecordsKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                        NSDate *dateFromString1 = [dateFormatter dateFromString:(NSString*)obj1];
                        NSDate *dateFromString2 = [dateFormatter dateFromString:(NSString*)obj2];
                        
                        if ([dateFromString1 compare:dateFromString2] == NSOrderedDescending) {
                            return (NSComparisonResult)NSOrderedAscending;
                        } else{
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    }];
                    NSArray *sanitizedCurrentUserRecordsKeysMutable = [[NSMutableArray alloc]initWithArray:sanitizedCurrentUserRecordsKeys];
                    [[NSUserDefaults standardUserDefaults] setObject:sanitizedCurrentUserRecordsKeysMutable forKey:[HConstants KSanitizedCurrentUserRecordsKeys]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kStartGetUserRecordsProcessNotification object:nil];
                }
                else {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants KSanitizedCurrentUserRecords]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants KSanitizedCurrentUserRecordsKeys]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kStartGetUserRecordsProcessNotification object:nil];
                }
            });
        }];
        
    });
}

-(void) loginUnsuccessful{
    if ([self.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
        [self.delegate loginUnsuccessful];
    }
}

- (void) manuallySetDelegate:(id<DataParserProtocol>)delegate{
    self.delegate = delegate;
}

-(Firebase*)records{
    if (!_records) {
        _records = [FireBaseManager recordURLsharedFireBase];
    }
    return _records;
}

@end
