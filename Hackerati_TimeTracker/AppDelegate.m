//
//  AppDelegate.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "AppDelegate.h"
#import <GooglePlus/GooglePlus.h>
#import "LogInManager.h"
#import "DataParser.h"
#import "WeeklyNotificationManager.h"
#import <HockeySDK/HockeySDK.h>

@interface AppDelegate ()

@property (nonatomic, strong) Reachability* internetReachability;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"3aa549db112abed50654d253ecec9aa7"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    [[BITHockeyManager sharedHockeyManager] testIdentifier];
    
    application.applicationIconBadgeNumber = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDelegatestartLogInProcess) name:kStartLogInProcessNotification object:nil];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.logInViewController = [[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil];
    
    [self setupReachability];
    [[LogInManager sharedManager] mannuallySetDelegate:[DataParser sharedManager]];
    [[DataParser sharedManager] mannuallySetDelegate:self.logInViewController];
    
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.logInViewController];
    self.window.rootViewController = self.naviController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)setupReachability{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
}

- (void)reachabilityChanged:(NSNotification *)note {
    // called after network status changes
    Reachability* curReach = [note object];
    NetworkStatus internetStatus = [curReach currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        [self appDelegatestartLogInProcess];
    }
    
}


- (void)appDelegatestartLogInProcess{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LogInManager sharedManager] startLogInProcess];
    });
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
#endif
    [WeeklyNotificationManager sharedManager];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}

@end
