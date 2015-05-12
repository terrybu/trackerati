//
//  User.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

class User : NSObject
{
    private(set) var email: String
    
    init(email: String)
    {
        self.email = email
    }
}
