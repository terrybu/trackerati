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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            [self.projects observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = snapshot.value;
                    __block NSMutableDictionary *newData = [[NSMutableDictionary alloc]init];
                    
                    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        NSDictionary *projectDictionary = (NSDictionary*) obj;
                        NSArray *projectsArray = [projectDictionary allKeys];
                        [newData setObject:projectsArray forKey:key];
                    }];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:newData forKey:[HConstants kMasterClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
                    __block NSMutableDictionary *tempCurrentUserClientList = [[NSMutableDictionary alloc]init];
                    __block NSMutableDictionary *tempCurrentUserClientList1 = [[NSMutableDictionary alloc]initWithDictionary:snapshot.value];
                    
                    [tempCurrentUserClientList1 enumerateKeysAndObjectsUsingBlock:^(id client, id obj, BOOL *stop){
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
                    if ([self.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate loginUnsuccessful];
                        });
                    }
                }
            }];
            self.records = [FireBaseManager recordURLsharedFireBase];
            [self.records observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *records = snapshot.value;
                    [[NSUserDefaults standardUserDefaults] setObject:records forKey:[HConstants KCurrentUserRecords]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                else {
                    if ([self.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate loginUnsuccessful];
                        });
                    }
                }
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
