//
//  LogInManager.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>

@protocol LogInManagerProtocol <NSObject>

-(void) loginSuccessful;
-(void) loginUnsuccessful;

@end

@interface LogInManager : NSObject <GPPSignInDelegate>

@property (nonatomic, weak) id <LogInManagerProtocol> delegate;

+ (LogInManager*)sharedManager;

- (void)startLogInProcess;

- (void)logOut;

- (void)mannuallySetDelegate:(id<LogInManagerProtocol>)delegate;

@end
