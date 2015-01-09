//
//  LastSavedManager.h
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastSavedManager : NSObject

+ (LastSavedManager*)sharedManager;
- (NSString*)getLastSavedHourForClient:(NSString*)client withProject:(NSString*)project withCurrentHour:(NSString*)hour;
- (void)saveClient:(NSString*)client withProject:(NSString*)project andHour:(NSString*)hour;
- (void)saveClient:(NSString*)client withProject:(NSString*)project withHour:(NSString*)hour andComment:(NSString*)comment;
-(NSString*)getLastSavedCommentForClient:(NSString*)client withProject:(NSString*)project;
@end
