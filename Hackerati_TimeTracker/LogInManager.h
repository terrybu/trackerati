//
//  LogInManager.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>

static NSString *kStartLogInProcessNotification = @"kStartLogInProcessNotification";
static NSString *kStartLogOutProcessNotification = @"kStartLogOutProcessNotification";
static NSString *kStartGetUserRecordsProcessNotification = @"kStartGetUserRecordsProcessNotification";

@protocol LogInManagerProtocol <NSObject>

-(void) getAllDataFromFireBaseAfterLoginSuccess;
-(void) loginUnsuccessful;

@end


@interface LogInManager : NSObject <GPPSignInDelegate>

@property (nonatomic, weak) id <LogInManagerProtocol> delegate;

+ (LogInManager*)sharedManager;

- (void)startLogInProcess;
- (void)logOut;
- (void)manuallySetDelegate:(id<LogInManagerProtocol>)delegate;


+ (BOOL) loggedOut;
+ (void) setLoggedOut: (BOOL) value;

@end
