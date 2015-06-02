//
//  Project.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/28/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class Project : NSObject
{
    let name: String
    let users: [String]
    
    init(name: String, users: [String])
    {
        self.name = name
        self.users = users
        super.init()
    }
}
