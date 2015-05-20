//
//  Project.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/19/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

class Client : NSObject
{
    let companyName: String
    let projectNames: [String]

    init(companyName: String, projectNames: [String])
    {
        self.companyName = companyName
        self.projectNames = projectNames
    }
}
