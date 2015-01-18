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
    if (!mutableLastSavedInfo || [mutableLastSavedInfo count] == 0) {
        mutableLastSavedInfo = [NSMutableArray new];
        [mutableLastSavedInfo addObject:record];
    } else {
        
        [mutableLastSavedInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSDictionary *tempRecord = (NSDictionary*)obj;
            if ([[tempRecord objectForKey:[HConstants kClient]]isEqualToString:(NSString*)[record objectForKey:[HConstants kClient]]] && [[tempRecord objectForKey:[HConstants kProject]]isEqualToString:(NSString*)[record objectForKey:[HConstants kProject]]]) {
                [mutableLastSavedInfo removeObjectAtIndex:idx];
                [mutableLastSavedInfo addObject:record];
                *stop = YES;
            }
        }];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedRecord]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSDictionary*)getRecordForClient:(NSString*)client withProject:(NSString*)project{
    NSArray* lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedRecord]];
    __block NSDictionary*record = nil;
    [lastSavedInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSDictionary *tempRecord = (NSDictionary*)obj;
        if ([[tempRecord objectForKey:[HConstants kClient]]isEqualToString:client] && [[tempRecord objectForKey:[HConstants kProject]]isEqualToString:project]) {
            record = tempRecord;
            *stop = YES;
        }
    }];
    return record;
}

@end
