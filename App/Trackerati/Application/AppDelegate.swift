//
//  AppDelegate.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let hockeySDKIdentifier = "3aa549db112abed50654d253ecec9aa7"
    
    var window: UIWindow!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        TrackeratiUserDefaults.standardDefaults
        #if RELEASE
        self.configureHockeySDK()
        #endif
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let rootViewController = ViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return true
    }
    
    func configureHockeySDK()
    {
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier(hockeySDKIdentifier);
        BITHockeyManager.sharedHockeyManager().startManager();
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation();
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

