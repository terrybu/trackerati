//
//  FirebaseManager.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

class FirebaseManager : NSObject
{
    private var firebaseDB = Firebase()
    
    class var sharedManager : FirebaseManager {
    
        struct Static {
            static var instance : FirebaseManager?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = FirebaseManager()
        }
        
        return Static.instance!
    }
    
    func configureWithDatabaseURL(url: String)
    {
        assert(url != "", "Must be a valid URL")
        firebaseDB = Firebase(url: url)
    }
}
