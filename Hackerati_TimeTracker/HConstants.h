//
//  HConstants.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kIconDrawer;
extern NSString * const kCellReuseIdentifier;

@interface HConstants : NSObject

+(NSString*)kClientId;
+(NSString*)kFireBaseURL;
+(NSString*)kMasterClientList;
+(NSString*)kCurrentUser;
+(NSString*)kCurrentUserRecords;
+(NSString*)kCurrentUserClientList;
+(NSString*)kLastSavedRecord;
+(NSString*)kRawMasterClientList;
+(NSString*)kSanitizedCurrentUserRecords;
+(NSString*)kFullTimeEmployee;
+(NSString*)kPartTimeEmployee;
+(NSString*)kBillableHour;
+(NSString*)kUnbillableHour;
+(NSString*)kClient;
+(NSString*)kProject;
+(NSString*)kDate;
+(NSString*)kHour;
+(NSString*)kComment;
+(NSString*)kStatus;
+(NSString*)kType;

@end
