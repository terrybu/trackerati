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
#import "Reachability.h"

@interface LogInManager ()

@property (weak, nonatomic)GPPSignIn *signIn;

@end

@implementation LogInManager

+ (LogInManager*)sharedManager{
    static LogInManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[LogInManager alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:_sharedManager selector:@selector(logOut) name:kStartLogOutProcessNotification object:nil];
    });
    return _sharedManager;
}

- (void)startLogInProcess{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        weakSelf.signIn = [GPPSignIn sharedInstance];
        weakSelf.signIn.shouldFetchGoogleUserEmail = YES;
        weakSelf.signIn.clientID = [HConstants kClientId];
        weakSelf.signIn.scopes = @[ @"profile" ];
        weakSelf.signIn.delegate = self;
        
        Reachability* curReach = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [curReach currentReachabilityStatus];
        
        if (internetStatus != NotReachable) {
            
            @try {
                if (weakSelf.signIn && ![weakSelf.signIn trySilentAuthentication]) {
                    [weakSelf.signIn authenticate];
                }
            }
            @catch (NSException *exception) {
                [self logOut];
                [[NSNotificationCenter defaultCenter] postNotificationName:kStartLogInProcessNotification object:nil];
            }
            @finally {
                
            }
            
        }
        
    });
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (error != nil) {
            // There was an error obtaining the Google+ OAuth token
            
            Reachability* curReach = [Reachability reachabilityForInternetConnection];
            NetworkStatus internetStatus = [curReach currentReachabilityStatus];
            if (internetStatus != NotReachable) {
                if ([weakSelf.delegate respondsToSelector:@selector(loginUnsuccessful)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate loginUnsuccessful];
                    });
                }
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
                                                               // Error authenticating Firebase with Google OAuth token
                                                               
                                                           } else {
                                                               // User is now logged in!
                                                               if ([weakSelf.delegate respondsToSelector:@selector(loginSuccessful)]) {
                                                                   [weakSelf.delegate loginSuccessful];
                                                               }
                                                           }
                                                       }];
        }
    });
}

- (void)mannuallySetDelegate:(id<LogInManagerProtocol>)delegate{
    self.delegate = delegate;
}

- (void)logOut{
    // Clean out NSUserDefault and Clear FireBase Managers
    [[GPPSignIn sharedInstance] signOut];
    [[FireBaseManager recordURLsharedFireBase] removeAllObservers];
    [[FireBaseManager projectURLsharedFireBase] removeAllObservers];
    [[FireBaseManager baseURLsharedFireBase] removeAllObservers];
    [[FireBaseManager baseURLsharedFireBase]unauth];
    [[FireBaseManager projectURLsharedFireBase]unauth];
    [[FireBaseManager recordURLsharedFireBase]unauth];
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
