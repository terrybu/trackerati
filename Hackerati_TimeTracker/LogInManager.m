//
//  LogInManager.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "LogInManager.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "FireBaseManager.h"
#import "HConstants.h"

@implementation LogInManager

+ (LogInManager*)sharedManager{
    static LogInManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[LogInManager alloc]init];
    });
    return _sharedManager;
}

- (void)startLogInProcess{
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    //signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = [HConstants kClientId];
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    //signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    if (![signIn trySilentAuthentication]) {
        [signIn authenticate];
    }
    
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error{
    if (error != nil) {
        // There was an error obtaining the Google+ OAuth token
        if ([self.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate loginUnsuccessful];
            });
        }
    } else {
        // We successfully obtained an OAuth token, authenticate on Firebase with it
        NSString *userEmail = [GPPSignIn sharedInstance].userEmail;
        NSString *username = [[userEmail componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:[HConstants KCurrentUser]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [[FireBaseManager baseURLsharedFireBase] authWithOAuthProvider:@"google" token:auth.accessToken
               withCompletionBlock:^(NSError *error, FAuthData *authData) {
                   if (error) {
                       // Error authenticating with Firebase with OAuth token
                       if ([self.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self.delegate loginUnsuccessful];
                           });
                       }
                   } else {
                       // User is now logged in!
                       if ([self.delegate respondsToSelector:@selector(loginSuccessful)]) {
                               [self.delegate loginSuccessful];
                       }
                   }
               }];
    }
}

- (void)mannuallySetDelegate:(id<LogInManagerProtocol>)delegate{
    self.delegate = delegate;
}

- (void)logOut{
    
}

@end
