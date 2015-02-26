//
//  AppDelegate.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "AppDelegate.h"
#import <GooglePlus/GooglePlus.h>
#import "LoginManager.h"
#import "DataParseManager.h"
#import "WeeklyNotificationManager.h"
#import <HockeySDK/HockeySDK.h>
#import "FireBaseManager.h"
#import "HConstants.h"
#import "HistoryViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "DrawerTableViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureHockey];
    [self configureNotifications:application];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDelegatestartLoginProcess) name:kStartLoginProcessNotification object:nil];
    [LoginManager setLoggedOut:YES];

    self.loginViewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    
    [[LoginManager sharedManager] manuallySetDelegate:[DataParseManager sharedManager]];
    [[DataParseManager sharedManager] manuallySetDelegate:self.loginViewController];
    [self appDelegatestartLoginProcess];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [self setUpStructureForFloatingDrawer];
    [self setUpSpringAnimator];
    self.window.rootViewController = self.drawerViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)configureHockey {
    // Override point for customization after application launch.
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"3aa549db112abed50654d253ecec9aa7"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    [[BITHockeyManager sharedHockeyManager] testIdentifier];
}

- (void)configureNotifications:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    [WeeklyNotificationManager sharedManager];
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)appDelegatestartLoginProcess{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoginManager sharedManager] startLoginProcess];
    });
}

#pragma mark - Helper Methods for Drawer
+ (AppDelegate *)globalDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}

- (void)setUpStructureForFloatingDrawer {
    self.drawerViewController = [[JVFloatingDrawerViewController alloc]init];
    
    UINavigationController *homeViewNavController = [[UINavigationController alloc]initWithRootViewController:[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil]];
    UINavigationController *historyViewNavController = [[UINavigationController alloc]initWithRootViewController:[[HistoryViewController alloc]initWithNibName:@"HistoryViewController" bundle:nil]];
    
    //could have used an array here but this data structure is needed to bounce back and forth freely when the left drawer table vc is selected and we gotta jump between these controllers. Dictionary seemed fine.
    self.controllersDictionary = [[NSMutableDictionary alloc]init];
    [self.controllersDictionary setObject:homeViewNavController forKey:kHomeNavControllerKey];
    [self.controllersDictionary setObject:historyViewNavController forKey:kHistoryNavControllerKey];
    
    self.drawerViewController.centerViewController = homeViewNavController;
    self.drawerViewController.leftViewController = [[DrawerTableViewController alloc]initWithNibName:@"DrawerTableViewController" bundle:nil];
    self.drawerViewController.backgroundImage = [UIImage imageNamed:@"hackworld"];
}

- (void)setUpSpringAnimator {
    JVFloatingDrawerSpringAnimator *animator = [[JVFloatingDrawerSpringAnimator alloc] init];
    self.drawerViewController.animator = animator;
    animator.animationDuration = .70;
    animator.animationDelay = 0;
    animator.initialSpringVelocity = 10;
    animator.springDamping = 1.8;
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
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}

@end
