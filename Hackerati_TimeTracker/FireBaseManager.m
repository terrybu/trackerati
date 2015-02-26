//
//  FireBaseManager.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "FireBaseManager.h"
#import "HConstants.h"

@implementation FireBaseManager

+ (Firebase*)baseURLsharedFireBase{
    static Firebase *baseURLsharedFireBase = nil;
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        baseURLsharedFireBase = [[Firebase alloc] initWithUrl:[HConstants kFireBaseURL]];
    });
    return baseURLsharedFireBase;
}

+ (Firebase*)projectURLsharedFireBase{
    static Firebase *projectURLsharedFireBase = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        projectURLsharedFireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects",[HConstants kFireBaseURL]]];
    });
    return projectURLsharedFireBase;
}

+ (Firebase*)recordURLsharedFireBase{
    //we can't use dispatch_once token here because when a user logs out, we need to change the recordURL accordingly based on username, which change based on which user logs in
    //if we use dispatch once_token here as well as a static Firebase variable, we had a bug where when another user logs in, the History of Records would still pull from previous user that was logged in
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
    Firebase *recordURLsharedFireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records",[HConstants kFireBaseURL],username]];
    return recordURLsharedFireBase;
}


+ (Firebase*)connectivityURLsharedFireBase{
    static Firebase *connectivityURLsharedFireBase = nil;
    static dispatch_once_t onceToken4;
    dispatch_once(&onceToken4, ^{
        connectivityURLsharedFireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@//.info/connected",[HConstants kFireBaseURL]]];
    });
    return connectivityURLsharedFireBase;
}



@end
