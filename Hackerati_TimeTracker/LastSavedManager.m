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

- (NSString*)getLastSavedHourForClient:(NSString*)client withProject:(NSString*)project withCurrentHour:(NSString*)hour{
    NSDictionary * lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedRecord]];
    NSString *returnHour = hour;
    if ([lastSavedInfo objectForKey:client] && [[lastSavedInfo objectForKey:client]objectForKey:project] &&[[[lastSavedInfo objectForKey:client]objectForKey:project] objectForKey:@"hour"]) {
        returnHour = [[[lastSavedInfo objectForKey:client]objectForKey:project] objectForKey:@"hour"];
    }
    
    return returnHour;
}

-(NSString*)getLastSavedCommentForClient:(NSString*)client withProject:(NSString*)project{
    NSDictionary * lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedRecord]];
    NSString *returnString = nil;
    if ([lastSavedInfo objectForKey:client] && [[lastSavedInfo objectForKey:client]objectForKey:project] &&[[[lastSavedInfo objectForKey:client]objectForKey:project] objectForKey:@"hour"]) {
        returnString = [[[lastSavedInfo objectForKey:client]objectForKey:project] objectForKey:@"comment"];
    }
    
    return returnString;
}

- (void)saveClient:(NSString*)client withProject:(NSString*)project withHour:(NSString*)hour andComment:(NSString*)comment{
    NSDictionary * lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedRecord]];
    NSMutableDictionary *mutableLastSavedInfo = [[NSMutableDictionary alloc]initWithDictionary:lastSavedInfo];
    if (![lastSavedInfo objectForKey:client]) {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setObject:@{@"hour":hour,@"comment":comment} forKey:project];
        [mutableLastSavedInfo setObject:tempDict forKey:client];
        [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedRecord]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } else {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[lastSavedInfo objectForKey:client]];
        [tempDict setObject:@{@"hour":hour,@"comment":comment} forKey:project];
        [mutableLastSavedInfo setObject:tempDict forKey:client];
        [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedRecord]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}


- (void)saveClient:(NSString*)client withProject:(NSString*)project andHour:(NSString*)hour{
    NSDictionary * lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedRecord]];
    NSMutableDictionary *mutableLastSavedInfo = [[NSMutableDictionary alloc]initWithDictionary:lastSavedInfo];
    if (![lastSavedInfo objectForKey:client]) {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setObject:@{@"hour":hour} forKey:project];
        [mutableLastSavedInfo setObject:tempDict forKey:client];
        [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedRecord]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } else {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[lastSavedInfo objectForKey:client]];
        [tempDict setObject:@{@"hour":hour} forKey:project];
        [mutableLastSavedInfo setObject:tempDict forKey:client];
        [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedRecord]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
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
