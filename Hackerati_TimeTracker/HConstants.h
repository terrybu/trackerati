//
//  HConstants.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HConstants : NSObject

+(NSString*)kClientId;
+(NSString*)kFireBaseURL;
+(NSString*)kMasterClientList;
+(NSString*)KCurrentUser;
+(NSString*)KCurrentUserRecords;
+(NSString*)KcurrentUserClientList;
+(NSString*)KlastSavedRecord;
+(NSString*)kRawMasterClientList;
+(NSString*)KSanitizedCurrentUserRecords;
+(NSString*)KSanitizedCurrentUserRecordsKeys;
+(NSString*)KfullTimeEmployee;
+(NSString*)KpartTimeEmployee;
+(NSString*)KbillableHour;
+(NSString*)KunbillableHour;
+(NSString*)kClient;
+(NSString*)kProject;
+(NSString*)kDate;
+(NSString*)kHour;
+(NSString*)kComment;
+(NSString*)kStatus;
+(NSString*)kType;

@end
