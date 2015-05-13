//
//  TrackeratiUserDefaults.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

enum DefaultsKey: String {
    case User = "user"
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
    
    let nilValue = ""
    
    func registerDefaults()
    {
        let initialDefaults = [DefaultsKey.User.rawValue: nilValue]
        NSUserDefaults.standardUserDefaults().registerDefaults(initialDefaults)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func logOutUser()
    {
        NSUserDefaults.standardUserDefaults().setValue(nilValue, forKey: DefaultsKey.User.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func setCurrentUser(user: String)
    {
        NSUserDefaults.standardUserDefaults().setValue(user, forKey: DefaultsKey.User.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func currentUser() -> String
    {
        return NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKey.User.rawValue)!
    }
}
