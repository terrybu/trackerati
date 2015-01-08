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
    NSDictionary * lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedHour]];
    NSString *returnHour = hour;
    if ([lastSavedInfo objectForKey:client] && [[lastSavedInfo objectForKey:client]objectForKey:project] ) {
        returnHour = [[lastSavedInfo objectForKey:client]objectForKey:project];
    } else{
        [self saveClient:client withProject:project andHour:hour];
    }
    
    return returnHour;
}

- (void)saveClient:(NSString*)client withProject:(NSString*)project andHour:(NSString*)hour{
    NSDictionary * lastSavedInfo =[[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KlastSavedHour]];
    NSMutableDictionary *mutableLastSavedInfo = [[NSMutableDictionary alloc]initWithDictionary:lastSavedInfo];
    if (![lastSavedInfo objectForKey:client]) {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setObject:hour forKey:project];
        [mutableLastSavedInfo setObject:tempDict forKey:client];
        [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedHour]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } else {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithDictionary:[lastSavedInfo objectForKey:client]];
        [tempDict setObject:hour forKey:project];
        [mutableLastSavedInfo setObject:tempDict forKey:client];
        [[NSUserDefaults standardUserDefaults] setObject:mutableLastSavedInfo forKey:[HConstants KlastSavedHour]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

@end
