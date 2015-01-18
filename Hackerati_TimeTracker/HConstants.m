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
static NSString * const kMasterClientList = @"MasterClientsList";
static NSString * const kRawMasterClientList = @"RawMasterClientsList";
static NSString * const KCurrentUser = @"currentUser";
static NSString * const KCurrentUserRecords = @"currentUserRecords";
static NSString * const KcurrentUserClientList = @"currentUserClientList";
static NSString * const KlastSavedRecord = @"lastSavedRecord";
static NSString * const KSanitizedCurrentUserRecords = @"SanitizedCurrentUserRecords";
static NSString * const KSanitizedCurrentUserRecordsKeys = @"SanitizedCurrentUserRecordsKeys";
static NSString * const KfullTimeEmployee = @"Full-Time Employee";
static NSString * const KpartTimeEmployee = @"Part-Time Employee";
static NSString * const KbillableHour = @"Billable Hour";
static NSString * const KunbillableHour = @"Unbillable Hour";
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

+(NSString*)KCurrentUser{
    return KCurrentUser;
}

+(NSString*)KCurrentUserRecords{
    return KCurrentUserRecords;
}

+(NSString*)KcurrentUserClientList{
    return KcurrentUserClientList;
}

+(NSString*)KlastSavedRecord{
    return KlastSavedRecord;
}

+(NSString*)kRawMasterClientList{
    return kRawMasterClientList;
}

+(NSString*)KSanitizedCurrentUserRecords{
    return KSanitizedCurrentUserRecords;
}

+(NSString*)KSanitizedCurrentUserRecordsKeys{
    return KSanitizedCurrentUserRecordsKeys;
}

+(NSString*)KfullTimeEmployee{
    return KfullTimeEmployee;
}

+(NSString*)KpartTimeEmployee{
    return KpartTimeEmployee;
}

+(NSString*)KbillableHour{
    return KbillableHour;
}

+(NSString*)KunbillableHour{
    return KunbillableHour;
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
