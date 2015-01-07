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
    static Firebase *recordURLsharedFireBase = nil;
    static dispatch_once_t onceToken3;
    dispatch_once(&onceToken3, ^{
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
        recordURLsharedFireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records",[HConstants kFireBaseURL],username]];
    });
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
