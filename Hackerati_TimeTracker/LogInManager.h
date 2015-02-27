//
//  LoginManager.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>

static NSString *kStartLoginProcessNotification = @"kStartLoginProcessNotification";
static NSString *kStartLogOutProcessNotification = @"kStartLogOutProcessNotification";
static NSString *kStartGetUserRecordsProcessNotification = @"kStartGetUserRecordsProcessNotification";

@protocol LoginManagerProtocol <NSObject>

-(void) getAllDataFromFireBase;
-(void) loginUnsuccessful;

@end


@interface LoginManager : NSObject <GPPSignInDelegate>

@property (nonatomic, weak) id <LoginManagerProtocol> delegate;

+ (LoginManager*)sharedManager;

- (void)startLoginProcess;
- (void)logOut;
- (void)manuallySetDelegate:(id<LoginManagerProtocol>)delegate;


+ (BOOL) loggedOut;
+ (void) setLoggedOut: (BOOL) value;

@end
