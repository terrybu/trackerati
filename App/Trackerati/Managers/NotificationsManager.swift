//
//  NotificationsManager.swift
//  Trackerati
//
//  Created by Terry Bu on 8/31/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class NotificationsManager {
    
    static let sharedInstance = NotificationsManager()
    
    func registerForNotifications() {
        if(self.isiOS8()) {
            self.registerForActionableNotification()
        } else {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
        }
    }

    func configureLocalNotifications() {
        if TrackeratiUserDefaults.standardDefaults.notificationsOn() && UIApplication.sharedApplication().scheduledLocalNotifications.count == 0 {
            fireNotificationsForMonToFri()
        }
        println(UIApplication.sharedApplication().scheduledLocalNotifications)
    }
    
    func registerForActionableNotification() {
        println("register for actionable notifications");
        let submitAction = UIMutableUserNotificationAction()
        submitAction.activationMode = UIUserNotificationActivationMode.Background
        submitAction.title = "Yes, submit"
        submitAction.identifier = kSubmitActionIdentifier
        //the submit acton's identifier will be passed to the delegate method in appdelegate once user clicks on the action
        submitAction.destructive = false
        submitAction.authenticationRequired = false

        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = kMutableNotificationCategory
        actionCategory.setActions([submitAction], forContext: UIUserNotificationActionContext.Default)
        
        var categories = NSSet(object: actionCategory)
        var types = UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: categories as Set<NSObject>)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(types)
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
        if isiOS8() {
            localNotification.category = kMutableNotificationCategory
            localNotification.alertBody = composeActionableNotificationMessage()
        } else {
            localNotification.alertBody = "Did you record your hours on Trackerati today?"
        }
        localNotification.alertAction = "Record"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    private func composeActionableNotificationMessage() -> String? {
        var lastSavedRecord = FirebaseManager.sharedManager.userRecordsSortedByDateInTuples![0].1.last
        if let record = lastSavedRecord {
            var message = "Want to submit \(record.client): \(record.project) for \(record.hours) hours today?"
            return message
        }
        return nil
    }
    
    func submitLastRecordForActionableNotification() {
        if let latestRecord = FirebaseManager.sharedManager.latestRecord {
            //check if today already had that same record submitted by project name. If so, don't put it in again through actionable notification
            //actionable notification cannot be prevented from firing at this time because we are repeating at weekly interval
            //we can improve this by firing notification daily and checking for weekends and also if todays record has already been submitted ... but daily firing complicates app because then we need a solution to work around weekends when we fire on Friday.
            //For the time being, we are having it do nothing if this case happens
            
            let todaysRecords = FirebaseManager.sharedManager.getTodaysRecords()
            if let todaysRecords = todaysRecords {
                for todaysRecord in todaysRecords {
                    if todaysRecord.client == latestRecord.client && todaysRecord.project == latestRecord.project {
                        println("don't submit anything with action notif because we found that you already logged \(latestRecord.project) for today")
                        return
                    }
                }
            }
            println("post through actionable notif because validation checking went smooth!")
            FirebaseManager.sharedManager.saveNewRecordBasedOnPastRecord(latestRecord, completion: { (error) -> Void in
                if (error != nil) {
                    println(error)
                }
            })
        }
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
    
    
    func resetNotifications() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    private func isiOS8() -> Bool {
        let Device = UIDevice.currentDevice()
        let iosVersion = NSString(string: Device.systemVersion).doubleValue
        if iosVersion >= 8 {
            println("ios 8 or higher")
            return true
        }
        return false
    }
    
}