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
//        if(self.isiOS8()) {
            self.registerForActionableNotification()
//        } else {
//            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
//        }
    }

    func configureLocalNotifications() {
        if TrackeratiUserDefaults.standardDefaults.notificationsOn()
            && UIApplication.sharedApplication().scheduledLocalNotifications!.count == 0 {
            fireNotificationsForMonToFri()
        }
        print(UIApplication.sharedApplication().scheduledLocalNotifications!)
        print(UIApplication.sharedApplication().scheduledLocalNotifications!.count)
        print(UIApplication.sharedApplication().scheduledLocalNotifications!.last?.description)
    }
    
    func registerForActionableNotification() {
        print("register for actionable notifications");
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
        
        let categories = Set<UIUserNotificationCategory>(arrayLiteral:actionCategory)
        let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    private func fireNotificationsForMonToFri() {
        let fireTime = TrackeratiUserDefaults.standardDefaults.notificationTime()
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components(([.Hour, .Minute]), fromDate: fireTime!)
//        let hour = comp.hour
//        let minute = comp.minute

        //we are going to check if we already posted earlier today (any record)
        //if we did, we are going to assume we don't have to remind user again on same day
        //**although we might have to update in future for cases like Donny that has multiple records to be posted on a single day ... one post earlier doesn't mean he's done posting for the day .. but for majority of cases, this will work
        
        if FirebaseManager.sharedManager.todayHasRecord {
            //today we already posted record. Then we shouldn't fire notif for today when we go to background
            //check what day of week today is
            print("today already has posted record")
            let today = NSDate()
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            let todayComponents = calendar?.components(.Weekday, fromDate: today)
            let todaysWeekDay = todayComponents!.weekday //Sunday is 1
            //day + 7 ... just for Monday's firing, and override the below switch statement
            let nextWeekDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 7, toDate: today, options: NSCalendarOptions(rawValue: 0))!
            print(nextWeekDate.description)
            switch(todaysWeekDay) {
            case WeekDayType.Monday.rawValue:
                fireNotificationsForWeekExceptForThis(WeekDayType.Monday, nextWeekDate: nextWeekDate, comp: comp, calendar: calendar!)
                break
            case WeekDayType.Tuesday.rawValue:
                fireNotificationsForWeekExceptForThis(WeekDayType.Tuesday, nextWeekDate: nextWeekDate, comp: comp, calendar: calendar!)
                break
            case WeekDayType.Wednesday.rawValue:
                fireNotificationsForWeekExceptForThis(WeekDayType.Wednesday, nextWeekDate: nextWeekDate, comp: comp, calendar: calendar!)
                break
            case WeekDayType.Thursday.rawValue:
                fireNotificationsForWeekExceptForThis(WeekDayType.Thursday, nextWeekDate: nextWeekDate, comp: comp,calendar: calendar!)
                break
            case WeekDayType.Friday.rawValue:
                fireNotificationsForWeekExceptForThis(WeekDayType.Friday, nextWeekDate: nextWeekDate, comp: comp,calendar: calendar!)
                break
            default:
                break
            }
        } else { //else proceed as normal
            fireNotificationForDay(.Monday, comp: comp)
            fireNotificationForDay(.Tuesday, comp: comp)
            fireNotificationForDay(.Wednesday, comp: comp)
            fireNotificationForDay(.Thursday, comp: comp)
            fireNotificationForDay(.Friday, comp: comp)
        }
    }
    
    private func fireNotificationsForWeekExceptForThis(weekDay: WeekDayType, nextWeekDate: NSDate, comp: NSDateComponents, calendar: NSCalendar) {
        print("fire notifications for week except for day \(weekDay.rawValue)")
        var daysSet : Set<WeekDayType> = [WeekDayType.Monday, .Tuesday, .Wednesday, .Thursday, .Friday]
        //first, fire off this thing for next week
        let flags: NSCalendarUnit = [NSCalendarUnit.Day, .Month, .Year]
        let nextWeekDateComponents = calendar.components(flags, fromDate: nextWeekDate)
        let year = nextWeekDateComponents.year
        let month = nextWeekDateComponents.month
        let day = nextWeekDateComponents.day
        print("\(year) \(month) and \(day)")
        nextWeekDateComponents.hour = comp.hour
        nextWeekDateComponents.minute = comp.minute
        self.fireThisNotificationWeekly(nextWeekDateComponents)
        //then get rid of it from daysSet
        daysSet.remove(weekDay)
        //then iterate over daysSet and send notification for all the other days
        for weekday in daysSet {
            fireNotificationForDay(weekday, comp: comp)
        }
    }
    
    private func fireNotificationForDay(day: WeekDayType, comp: NSDateComponents) {
        switch (day) {
        case .Monday:
            self.fireThisNotificationWeekly(returnDateComponents(2015, month: 2, day: 23, comp: comp))
            break
        case .Tuesday:
            self.fireThisNotificationWeekly(returnDateComponents(2015, month: 2, day: 24, comp: comp))
            break
        case .Wednesday:
            self.fireThisNotificationWeekly(returnDateComponents(2015, month: 2, day: 25, comp: comp))
            break
        case .Thursday:
            self.fireThisNotificationWeekly(returnDateComponents(2015, month: 2, day: 26, comp: comp))
            break
        case .Friday:
            self.fireThisNotificationWeekly(returnDateComponents(2015, month: 2, day: 27, comp: comp))
            break
        default:
            break
        }
    }
    
    private func returnDateComponents(year: Int, month: Int, day: Int, comp: NSDateComponents ) -> NSDateComponents {
        let dateComponents = NSDateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = comp.hour
        dateComponents.minute = comp.minute
        return dateComponents
    }
    
    private func fireThisNotificationWeekly(dateComponents: NSDateComponents) {
        let localNotification = UILocalNotification()
        localNotification.repeatInterval = NSCalendarUnit.NSWeekCalendarUnit
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
        let lastSavedRecord = FirebaseManager.sharedManager.userRecordsSortedByDateInTuples![0].1.last
        if let record = lastSavedRecord {
            let message = "Want to submit \(record.client): \(record.project) for \(record.hours) hours today?"
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
                        print("don't submit anything with action notif because we found that you already logged \(latestRecord.project) for today")
                        return
                    }
                }
            }
            print("post through actionable notif because validation checking went smooth!")
            FirebaseManager.sharedManager.saveNewRecordBasedOnPastRecord(latestRecord, completion: { (error) -> Void in
                if (error != nil) {
                    print(error)
                }
            })
        }
    }

    
    //To-DO: we need this below to find if we are trying to fire on a Holiday later
    //we don't use this method anywhere for the time being
    private func findNextNotificationDate(notification: UILocalNotification)  -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let difference = calendar.components(notification.repeatInterval, fromDate: notification.fireDate!, toDate: NSDate(), options: NSCalendarOptions())
        var nextFireDate:NSDate! = calendar.dateByAddingComponents(difference, toDate: notification.fireDate!, options: NSCalendarOptions())
        if (nextFireDate.timeIntervalSinceDate(NSDate()) < 0) {
            let extraDay = NSDateComponents()
            extraDay.day = 1
            nextFireDate = calendar.dateByAddingComponents(extraDay, toDate: nextFireDate!, options: NSCalendarOptions())
        }
        return nextFireDate
    }
    
    private func findWeekdayFrom(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components:NSDateComponents = calendar.components(NSCalendarUnit.Weekday, fromDate: date)
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
            print("ios 8 or higher")
            return true
        }
        return false
    }
    
}