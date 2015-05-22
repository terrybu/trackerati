//
//  Record.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/20/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class Record : NSObject
{
    let id: String
    let client: String
    let date: String
    let hours: String
    let project: String
    let status: String
    let type: String
    let comment: String?
    
    init(id: String, client: String, date: String, hours: String, project: String, status: String, type: String, comment: String?)
    {
        self.id = id
        self.client = client
        self.date = date
        self.hours = hours
        self.project = project
        self.status = status
        self.type = type
        self.comment = comment
    }
    
}