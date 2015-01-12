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

#define NILIFNULL(foo) ((foo == [NSNull null]) ? nil : foo)
#define NULLIFNIL(foo) ((foo == nil) ? [NSNull null] : foo)
#define EMPTYIFNIL(foo) ((foo == nil) ? @"" : foo)

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
        
        self.records = [FireBaseManager recordURLsharedFireBase];
        [self.records observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *records = snapshot.value;
                    
                    __block NSMutableDictionary *sanitizedCurrentUserRecords = [[NSMutableDictionary alloc]init];
                    [records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([obj objectForKey:@"client"] && [obj objectForKey:@"project"] && [obj objectForKey:@"date"] && [obj objectForKey:@"hour"]) {
                            if ([sanitizedCurrentUserRecords objectForKey:[obj objectForKey:@"date"]] ) {
                                NSMutableArray *records = [sanitizedCurrentUserRecords objectForKey:[obj objectForKey:@"date"]];
                                if ([obj objectForKey:@"comment"]) {
                                    [records addObject:@{@"client":[obj objectForKey:@"client"],@"project":[obj objectForKey:@"project"],@"hour":[obj objectForKey:@"hour"],@"comment":[obj objectForKey:@"comment"]}];
                                } else{
                                    [records addObject:@{@"client":[obj objectForKey:@"client"],@"project":[obj objectForKey:@"project"],@"hour":[obj objectForKey:@"hour"]}];
                                }
                                [sanitizedCurrentUserRecords setObject:records forKey:[obj objectForKey:@"date"]];
                            } else{
                                NSMutableArray *records = nil;
                                if ([obj objectForKey:@"comment"]) {
                                    records = [[NSMutableArray alloc]initWithObjects:@{@"client":[obj objectForKey:@"client"],@"project":[obj objectForKey:@"project"],@"hour":[obj objectForKey:@"hour"],@"comment":[obj objectForKey:@"comment"]}, nil];
                                } else{
                                    records = [[NSMutableArray alloc]initWithObjects:@{@"client":[obj objectForKey:@"client"],@"project":[obj objectForKey:@"project"],@"hour":[obj objectForKey:@"hour"]}, nil];
                                }
                                [sanitizedCurrentUserRecords setObject:records forKey:[obj objectForKey:@"date"]];
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
                    [[NSUserDefaults standardUserDefaults] setObject:sanitizedCurrentUserRecordsKeys forKey:[HConstants KSanitizedCurrentUserRecordsKeys]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                else {
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants KSanitizedCurrentUserRecords]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[HConstants KSanitizedCurrentUserRecordsKeys]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    if ([self.delegate respondsToSelector:@selector(loadData)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate loadData];
                        });
                    }
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

- (void) mannuallySetDelegate:(id<DataParserProtocol>)delegate{
    self.delegate = delegate;
}

@end
