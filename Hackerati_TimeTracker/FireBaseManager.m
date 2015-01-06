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

+ (Firebase*)sharedFireBase{
    static Firebase *shareFireBase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareFireBase = [[Firebase alloc] initWithUrl:[HConstants kFireBaseURL]];
    });
    return shareFireBase;
}

    
@end
