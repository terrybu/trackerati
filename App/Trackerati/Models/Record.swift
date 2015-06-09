//
//  Record.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/20/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

enum RecordKey: String
{
    case ID = "id"
    case Client = "client"
    case Date = "date"
    case Hours = "hour"
    case Project = "project"
    case Status = "status"
    case WorkType = "type"
    case Comment = "comment"
    
    static let editableValues = [Client, Date, Hours, Project, Status, WorkType, Comment]
}

class Record : NSObject
{
    let id: String
    var client: String
    var date: String
    var hours: String
    var project: String
    var status: String
    var type: String
    var comment: String?
    
    class var numberOfFields: Int {
        return RecordKey.editableValues.count
    }
    
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
    
    convenience init(client: String, project: String)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.init(id: "", client: client, date: dateFormatter.stringFromDate(NSDate()), hours: "8.0", project: project, status: "1", type: "1", comment: nil)
    }
    
    func valueForType(recordType: RecordKey, rawValue: Bool) -> String?
    {
        switch recordType
        {
        case .Client:
            return client
            
        case .Date:
            return date
            
        case .Hours:
            return hours
            
        case .Project:
            return project
            
        case .Status:
            if rawValue {
                return status
            }
            
            if let statusAsInt = status.toInt() {
                return kRecordStatusNames[statusAsInt]
            }
            else {
                return nil
            }
            
        case .WorkType:
            if rawValue {
                return type
            }
            
            if let workTypeAsInt = type.toInt() {
                return kRecordWorkTypeNames[workTypeAsInt]
            }
            else {
                return nil
            }

        case .Comment:
            return comment
            
        default:
            return nil
        }
    }
}