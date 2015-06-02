//
//  Project.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/19/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class Client : NSObject
{
    let companyName: String
    let projects: [Project]

    init(companyName: String, projects: [Project])
    {
        self.companyName = companyName
        self.projects = projects
    }
}
