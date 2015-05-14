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

    private let googleAPIKey = "478294020811-80olfgevlg8q14vo74lmmiu3nu7q75m5.apps.googleusercontent.com"
    private let firebaseAbsoluteURL = "https://blazing-torch-6772.firebaseio.com"
    private let hockeySDKIdentifier = "3aa549db112abed50654d253ecec9aa7"
    
    var window: UIWindow!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        
        #if RELEASE
        self.configureHockeySDK()
        #endif
        
        self.configureSingletons()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let containerViewController = ContainerViewController(centerViewController: HomeViewController(), sideMenuViewController: SideMenuViewController(items: SideMenuSelection.AllSelections))
        window.rootViewController = containerViewController
        window.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    private func configureHockeySDK()
    {
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier(hockeySDKIdentifier);
        BITHockeyManager.sharedHockeyManager().startManager();
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation();
    }
    
    private func configureSingletons()
    {
        TrackeratiUserDefaults.standardDefaults.registerDefaults()
        GoogleLoginManager.sharedManager.configureWithAPIKey(googleAPIKey)
        FirebaseManager.sharedManager.configureWithDatabaseURL(firebaseAbsoluteURL)
    }
}

