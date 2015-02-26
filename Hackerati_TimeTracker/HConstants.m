//
//  HConstants.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "HConstants.h"
NSString * const kIconDrawer = @"IconDrawer";
NSString * const kCellReuseIdentifier = @"DrawerCell";

static NSString * const kClientId = @"1074427376116-jjk9j3nbsgao64i8hne37fdrhf49bdqu.apps.googleusercontent.com";
static NSString * const kFireBaseURL = @"https://blazing-torch-6772.firebaseio.com";
static NSString * const kMasterClientList = @"MasterClientsList";
static NSString * const kRawMasterClientList = @"RawMasterClientsList";
static NSString * const kCurrentUser = @"currentUser";
static NSString * const kCurrentUserRecords = @"currentUserRecords";
static NSString * const kCurrentUserClientList = @"currentUserClientList";
static NSString * const kLastSavedRecord = @"lastSavedRecord";
static NSString * const kSanitizedCurrentUserRecords = @"SanitizedCurrentUserRecords";
static NSString * const kFullTimeEmployee = @"Full-Time Employee";
static NSString * const kPartTimeEmployee = @"Part-Time Employee";
static NSString * const kBillableHour = @"Billable Hour";
static NSString * const kUnbillableHour = @"Unbillable Hour";
static NSString * const kClient = @"client";
static NSString * const kProject = @"project";
static NSString * const kDate = @"date";
static NSString * const kHour = @"hour";
static NSString * const kComment = @"comment";
static NSString * const kStatus = @"status";
static NSString * const kType = @"type";

@implementation HConstants

+(NSString*)kClientId{
    return kClientId;
}

+(NSString*)kFireBaseURL{
    return kFireBaseURL;
}

+(NSString*)kMasterClientList{
    return kMasterClientList;
}

+(NSString*)kCurrentUser{
    return kCurrentUser;
}

+(NSString*)kCurrentUserRecords{
    return kCurrentUserRecords;
}

+(NSString*)kCurrentUserClientList{
    return kCurrentUserClientList;
}

+(NSString*)kLastSavedRecord{
    return kLastSavedRecord;
}

+(NSString*)kRawMasterClientList{
    return kRawMasterClientList;
}

+(NSString*)kSanitizedCurrentUserRecords{
    return kSanitizedCurrentUserRecords;
}

+(NSString*)kFullTimeEmployee{
    return kFullTimeEmployee;
}

+(NSString*)kPartTimeEmployee{
    return kPartTimeEmployee;
}

+(NSString*)kBillableHour{
    return kBillableHour;
}

+(NSString*)kUnbillableHour{
    return kUnbillableHour;
}

+(NSString*)kClient{
    return kClient;
}

+(NSString*)kProject{
    return kProject;
}

+(NSString*)kDate{
    return kDate;
}

+(NSString*)kHour{
    return kHour;
}

+(NSString*)kComment{
    return kComment;
}
+(NSString*)kStatus{
    return kStatus;
}
+(NSString*)kType{
    return kType;
}

@end
