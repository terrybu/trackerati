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
        #endif

        NewRelicAgent.startWithApplicationToken("AAd558e763f773d7bb68194513db0dcdac6aeff656")

        configureSingletons()
        
        //you need to register for local notifications like below before using them (to play sounds, show badge, etc)
        if(self.isiOS8()) {
            self.registerForActionableNotification()
        }
        else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
        }
  
//        resetNotification()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let containerViewController = ContainerViewController(centerViewController: HomeViewController(), sideMenuViewController: SideMenuViewController(items: SideMenuSelection.AllSelections))
        window?.rootViewController = containerViewController
        window?.makeKeyAndVisible()

        return true
    }
    
    private func isiOS8() -> Bool {
        let Device = UIDevice.currentDevice()
        let iosVersion = NSString(string: Device.systemVersion).doubleValue
        if iosVersion >= 8 {
            return true
        }
        return false
    }
    
    private func registerForActionableNotification() {
        let submitAction = UIMutableUserNotificationAction()
        submitAction.activationMode = UIUserNotificationActivationMode.Background
        submitAction.title = "Yes, submit"
        submitAction.identifier = kSubmitActionIdentifier
        submitAction.destructive = false
        submitAction.authenticationRequired = false
        
        //next time you make a UILocalNotification object's category, you set it to this category so that it will have this action associated with it 
        //and the submit acton's identifier will be passed to the delegate method in appdelegate once user clicks on the action
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = kMutableNotificationCategory
        actionCategory.setActions([submitAction], forContext: UIUserNotificationActionContext.Default)
        
        var categories = NSSet(object: actionCategory)
        var types = UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: categories as Set<NSObject>)

        UIApplication.sharedApplication().registerUserNotificationSettings(types)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if identifier == kSubmitActionIdentifier {
            LastSavedManager.sharedManager.submitLastRecordForActionableNotification()
            application.applicationIconBadgeNumber = 0
        }
        completionHandler()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        resetNotification()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        configureLocalNotifications()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        resetNotification()
        // TODO: Bring them to new draft for default projects
    }
    
    private func configureLocalNotifications()
    {
        if TrackeratiUserDefaults.standardDefaults.notificationsOn() && UIApplication.sharedApplication().scheduledLocalNotifications.count == 0 {
            fireNotificationsForMonToFri()
        }
        println(UIApplication.sharedApplication().scheduledLocalNotifications)
    }
    
    private func fireNotificationsForMonToFri() {
        fireNotificationForDay(.Monday)
        fireNotificationForDay(.Tuesday)
        fireNotificationForDay(.Wednesday)
        fireNotificationForDay(.Thursday)
        fireNotificationForDay(.Friday)
    }
    
    private func fireNotificationForDay(day: WeekDayType) {
        var fireTime = TrackeratiUserDefaults.standardDefaults.notificationTime()
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components((.CalendarUnitHour | .CalendarUnitMinute), fromDate: fireTime!)
        let hour = comp.hour
        let minute = comp.minute
        
        switch (day) {
        
        case .Monday:
            self.fireThisNotificationWeekly(self.setDateComponents(2015, month: 2, day: 23, hour: hour, minute: minute))
            break
        
        case .Tuesday:
            self.fireThisNotificationWeekly(self.setDateComponents(2015, month: 2, day: 24, hour: hour, minute: minute))
            break
        
        case .Wednesday:
            self.fireThisNotificationWeekly(self.setDateComponents(2015, month: 2, day: 25, hour: hour, minute: minute))
            break
            
        case .Thursday:
            self.fireThisNotificationWeekly(self.setDateComponents(2015, month: 2, day: 26, hour: hour, minute: minute))
            break
            
        case .Friday:
            self.fireThisNotificationWeekly(self.setDateComponents(2015, month: 2, day: 27, hour: hour, minute: minute))
            break
        
        default:
            break
        }
    }
    
    private func setDateComponents(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> NSDateComponents {
        var dateComponents = NSDateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        return dateComponents
    }
    
    private func fireThisNotificationWeekly(dateComponents: NSDateComponents) {
        let localNotification = UILocalNotification()
        localNotification.repeatInterval = NSCalendarUnit.WeekCalendarUnit
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.fireDate = NSCalendar.currentCalendar().dateFromComponents(dateComponents)
        if isiOS8() && LastSavedManager.sharedManager.getLastRecordForActionableNotification() != nil {
            localNotification.category = kMutableNotificationCategory
            localNotification.alertBody = composeActionableNotificationMessage()
        }
        else {
            localNotification.alertBody = "Did you record your hours on Trackerati today?"
        }
        localNotification.alertAction = "Record"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
//        println(localNotification.description)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    private func composeActionableNotificationMessage() -> String? {
        var lastSavedRecord = LastSavedManager.sharedManager.getLastRecordForActionableNotification()
        if let record = lastSavedRecord {
            var message = "Want to submit \(record.client): \(record.project) for \(record.hours) hours today?"
            return message
        }
        return nil
    }
    
    
    
    //To-DO: we need this below to find if we are trying to fire on a Holiday later
    //we don't use this method anywhere for the time being
    private func findNextNotificationDate(notification: UILocalNotification)  -> NSDate {
        var calendar = NSCalendar.currentCalendar()
        var difference = calendar.components(notification.repeatInterval, fromDate: notification.fireDate!, toDate: NSDate(), options: NSCalendarOptions.allZeros)
        var nextFireDate:NSDate! = calendar.dateByAddingComponents(difference, toDate: notification.fireDate!, options: NSCalendarOptions.allZeros)
        if (nextFireDate.timeIntervalSinceDate(NSDate()) < 0) {
            var extraDay = NSDateComponents()
            extraDay.day = 1
            nextFireDate = calendar.dateByAddingComponents(extraDay, toDate: nextFireDate!, options: NSCalendarOptions.allZeros)
        }
        return nextFireDate
    }
    
    private func findWeekdayFrom(date: NSDate) -> Int {
        var calendar = NSCalendar.currentCalendar()
        var components:NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: date)
        return components.weekday
        //Sunday 1 Monday 2 Tuesday 3 Wed 4 Thurs 5 Friday 6 Saturday 7
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

