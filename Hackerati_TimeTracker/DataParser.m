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

@interface DataParser ()

@property (nonatomic, strong) Firebase *projects;
@property (nonatomic, strong) Firebase *records;
@property (nonatomic, strong) NSString *username;

@end

@implementation DataParser

+ (DataParser*) sharedManager{
    static DataParser *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DataParser alloc]init];
        _sharedManager.projects = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects",[HConstants kFireBaseURL]]];
        _sharedManager.username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
        _sharedManager.records = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records",[HConstants kFireBaseURL],_sharedManager.username]];
    });
    return _sharedManager;
}

- (void) loginSuccessful{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            [self.projects observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = snapshot.value;
                    [[NSUserDefaults standardUserDefaults]setObject:data forKey:[HConstants kMasterClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
            }];
            
            [self.records observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
                if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *records = snapshot.value;
                    [[NSUserDefaults standardUserDefaults] setObject:records forKey:[HConstants KCurrentUserRecords]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    __block NSMutableDictionary *currentUserClientList = [[NSMutableDictionary alloc]init];
                    [records enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                            NSString *tClient = [(NSDictionary*)obj objectForKey:@"client"];
                            NSString *tProject = [(NSDictionary*)obj objectForKey:@"project"];
                            if (![currentUserClientList objectForKey:tClient]) {
                                NSMutableArray * projects = [[NSMutableArray alloc]initWithObjects:tProject, nil];
                                [currentUserClientList setObject:projects forKey:tClient];
                            }else {
                                NSMutableArray * projects = [currentUserClientList objectForKey:tClient];
                                if (![projects containsObject:tProject]) {
                                    [projects addObject:tProject];
                                }
                            }
                        }
                    }];
                    [[NSUserDefaults standardUserDefaults] setObject:currentUserClientList forKey:[HConstants KcurrentUserClientList]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    if ([self.delegate respondsToSelector:@selector(loadData)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate loadData];
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

- (void)mannuallySetDelegate:(id<DataParserProtocol>)delegate{
    self.delegate = delegate;
}

@end
