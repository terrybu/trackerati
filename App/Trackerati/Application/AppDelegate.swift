//
//  AppDelegate.swift
//  Trackerati
///Users/TerryBu/Desktop/trackerati-ios/App/Trackerati/Models/User.swift
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import HockeySDK

enum WeekDayType: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

let kSubmitActionIdentifier = "kMutableNotificationSubmitActionIdentifier"
let kMutableNotificationCategory = "kMutableNotificationCategory"

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
    NewRelicAgent.startWithApplicationToken("AAd558e763f773d7bb68194513db0dcdac6aeff656")
        #endif

        configureSingletons()
        
        //you need to register for local notifications like below before using them (to play sounds, show badge, etc)
        NotificationsManager.sharedInstance.registerForNotifications()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let containerViewController = ContainerViewController(centerViewController: HomeViewController(), sideMenuViewController: SideMenuViewController(items: SideMenuSelection.AllSelections))
        window?.rootViewController = containerViewController
        window?.makeKeyAndVisible()
        return true
    }
    
    private func configureHockeySDK() {
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier(hockeySDKIdentifier);
        BITHockeyManager.sharedHockeyManager().startManager();
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation();
    }
    
    private func configureSingletons() {
        TrackeratiUserDefaults.standardDefaults.registerDefaults()
        GoogleLoginManager.sharedManager.configureWithAPIKey(googleAPIKey)
        
        #if DEBUG
            FirebaseManager.sharedManager.configureWithDatabaseURL(firebaseAbsoluteURLDebug)
            print("debug mode")
        #else
            FirebaseManager.sharedManager.configureWithDatabaseURL(firebaseAbsoluteURLRelease)
            print("using production db")
        #endif
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    //MARK: Notifications handling
    
    func applicationWillEnterForeground(application: UIApplication) {
        NotificationsManager.sharedInstance.resetNotifications()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NotificationsManager.sharedInstance.resetNotifications()
        NotificationsManager.sharedInstance.configureLocalNotifications()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if identifier == kSubmitActionIdentifier {
            NotificationsManager.sharedInstance.submitLastRecordForActionableNotification()
            application.applicationIconBadgeNumber = 0
        }
        completionHandler()
    }

    
}

