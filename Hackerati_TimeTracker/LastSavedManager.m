//
//  LastSavedManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "LastSavedManager.h"
#import "HConstants.h"

@implementation LastSavedManager

+ (LastSavedManager*)sharedManager{
    static LastSavedManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[LastSavedManager alloc]init];
    });
    return shareManager;
}

-(void)saveRecord:(NSDictionary*)record{
    NSArray* lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedRecord]];
    NSMutableArray* mutableLastSavedInfo = [[NSMutableArray alloc]initWithArray:lastSavedInfo];
    if (!mutableLastSavedInfo) {
        mutableLastSavedInfo = [NSMutableArray new];
    }
    
    [mutableLastSavedInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSDictionary *tempRecord = (NSDictionary*)obj;
        if ([[tempRecord objectForKey:@"client"]isEqualToString:(NSString*)[record objectForKey:@"client"]] && [[tempRecord objectForKey:@"project"]isEqualToString:(NSString*)[record objectForKey:@"project"]]) {
            [mutableLastSavedInfo removeObjectAtIndex:idx];
            [mutableLastSavedInfo addObject:record];
            *stop = YES;
        }
    }];
    [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedRecord]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSDictionary*)getRecordForClient:(NSString*)client withProject:(NSString*)project{
    NSArray* lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedRecord]];
    __block NSDictionary*record = nil;
    [lastSavedInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSDictionary *tempRecord = (NSDictionary*)obj;
        if ([[tempRecord objectForKey:@"client"]isEqualToString:client] && [[tempRecord objectForKey:@"project"]isEqualToString:project]) {
            record = tempRecord;
            *stop = YES;
        }
    }];
    return record;
}

@end
