//
//  Record.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/20/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class Record : NSObject
{
    let client: String
    let date: String
    let hours: String
    let project: String
    let status: String
    let type: String
    
    init(client: String, date: String, hours: String, project: String, status: String, type: String)
    {
        self.client = client
        self.date = date
        self.hours = hours
        self.project = project
        self.status = status
        self.type = type
    }
    
}