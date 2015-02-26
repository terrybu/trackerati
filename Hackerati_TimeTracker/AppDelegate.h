//
//  AppDelegate.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "JVFloatingDrawerViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *logInViewController;
@property (strong, nonatomic) UINavigationController *naviController;

@property (nonatomic, strong) JVFloatingDrawerViewController *drawerViewController;
@property (nonatomic, strong) NSMutableDictionary *controllersDictionary;

+ (AppDelegate *)globalDelegate;
- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated;

@end

