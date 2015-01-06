//
//  HConstants.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "HConstants.h"

static NSString * const kClientId = @"1074427376116-jjk9j3nbsgao64i8hne37fdrhf49bdqu.apps.googleusercontent.com";
static NSString * const kFireBaseURL = @"https://blazing-torch-6772.firebaseio.com";
@implementation HConstants

+(NSString*)kClientId{
    return kClientId;
}

+(NSString*)kFireBaseURL{
    return kFireBaseURL;
}

@end
