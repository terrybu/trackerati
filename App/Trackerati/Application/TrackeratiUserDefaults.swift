//
//  TrackeratiUserDefaults.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

enum DefaultsKey: String {
    case Notifications = "notifications"
    case NotificationsTime = "notifications time"
    case EmploymentStatus = "employment status"
}

enum EmploymentStatusEnum: Int {
    case PartTime = 0, FullTime
}

class TrackeratiUserDefaults : NSObject
{
    class var standardDefaults : TrackeratiUserDefaults
    {
    
        struct Static {
            static var instance : TrackeratiUserDefaults?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = TrackeratiUserDefaults()
        }
    
        return Static.instance!
    }
    
    func registerDefaults()
    {
        let initialDefaults = [
            DefaultsKey.Notifications.rawValue: NSNumber(bool: false),
            DefaultsKey.EmploymentStatus.rawValue: EmploymentStatusEnum.FullTime.rawValue
        
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(initialDefaults)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: Notifications Related Defaults
    func setNotificationsOn(on: Bool)
    {
        NSUserDefaults.standardUserDefaults().setBool(on, forKey: DefaultsKey.Notifications.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func notificationsOn() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(DefaultsKey.Notifications.rawValue)
    }
    
    func setNotificationDate(date: NSDate)
    {
        NSUserDefaults.standardUserDefaults().setObject(date, forKey: DefaultsKey.NotificationsTime.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func notificationTime() -> NSDate?
    {
        return NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKey.NotificationsTime.rawValue) as? NSDate
    }
    
    // MARK: Employment Status Related Defaults
    func setEmploymentStatus(status: EmploymentStatusEnum) {
        NSUserDefaults.standardUserDefaults().setInteger(status.rawValue, forKey: DefaultsKey.EmploymentStatus.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getEmploymentStatus () -> EmploymentStatusEnum {
        let statusIntValue: Int = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKey.EmploymentStatus.rawValue) as! Int
        return statusIntValue == 0 ? EmploymentStatusEnum.PartTime : EmploymentStatusEnum.FullTime
    }
    
}
