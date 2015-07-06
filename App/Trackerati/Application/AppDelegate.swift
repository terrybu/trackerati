//
//  AppDelegate.swift
//  Trackerati
///Users/TerryBu/Desktop/trackerati-ios/App/Trackerati/Models/User.swift
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let googleAPIKey = "478294020811-80olfgevlg8q14vo74lmmiu3nu7q75m5.apps.googleusercontent.com"
    private let firebaseAbsoluteURLDebug = "https://trackerati-dev.firebaseio.com"
    private let firebaseAbsoluteURLRelease = "https://blazing-torch-6772.firebaseio.com"
//    private let hockeySDKIdentifier = "3aa549db112abed50654d253ecec9aa7" old one
    private let hockeySDKIdentifier = "64f4b2404dc31b38296a2a89eaaf23b7"

    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        
        #if RELEASE
        configureHockeySDK()
        #endif
    
        configureSingletons()
        resetNotification()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let containerViewController = ContainerViewController(centerViewController: HomeViewController(), sideMenuViewController: SideMenuViewController(items: SideMenuSelection.AllSelections))
        window?.rootViewController = containerViewController
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        resetNotification()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        configureLocalNotification()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        resetNotification()
        // TODO: Bring them to new draft for default projects
    }
    
    private func configureLocalNotification()
    {
        if TrackeratiUserDefaults.standardDefaults.notificationsOn() && UIApplication.sharedApplication().scheduledLocalNotifications.count < 1 {
            if let fireTime = TrackeratiUserDefaults.standardDefaults.notificationTime() {
                
                let localNotification = UILocalNotification()
                localNotification.repeatInterval = .CalendarUnitDay
                localNotification.timeZone = NSTimeZone.defaultTimeZone()
                localNotification.fireDate = fireTime
                // TODO: Put "better" alert body
                localNotification.alertBody = "Ain't nobody got time for that... except for you!"
                localNotification.applicationIconBadgeNumber = 1
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
        }
    }
    
    private func resetNotification()
    {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
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
        
        #if DEBUG
            FirebaseManager.sharedManager.configureWithDatabaseURL(firebaseAbsoluteURLDebug)
            println("debug mode")
        #else
            FirebaseManager.sharedManager.configureWithDatabaseURL(firebaseAbsoluteURLRelease)
            println("using production db")
        #endif
        
    }
}

