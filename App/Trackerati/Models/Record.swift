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

enum RecordKeyIndex: Int {
    case Client = 0, Date, Hours, Project, Status, WorkType, Comment
}


class Record : NSObject, NSCoding
{
    var id: String
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
        //default values when you are using the Form to submit a new record 
        self.init(id: "", client: client, date: CustomDateFormatter.sharedInstance.returnTodaysDateStringInFormat(), hours: "8.0", project: project, status: "1", type: "1", comment: nil)
    }
    
    required init?(coder decoder: NSCoder) {
        self.id = decoder.decodeObjectForKey("id") as! String
        self.client = decoder.decodeObjectForKey("client") as! String
        self.date = decoder.decodeObjectForKey("date") as! String
        self.hours = decoder.decodeObjectForKey("hours") as! String
        self.project = decoder.decodeObjectForKey("project") as! String
        self.status = decoder.decodeObjectForKey("status") as! String
        self.type = decoder.decodeObjectForKey("type") as! String
        self.comment = decoder.decodeObjectForKey("comment") as? String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.client, forKey: "client")
        coder.encodeObject(self.date, forKey: "date")
        coder.encodeObject(self.hours, forKey: "hours")
        coder.encodeObject(self.project, forKey: "project")
        coder.encodeObject(self.status, forKey: "status")
        coder.encodeObject(self.type, forKey: "type")
        coder.encodeObject(self.comment, forKey: "comment")
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
                //this means with rawValue true, it will return a string like "0" or "1" because that's how we save in Firebase
                //"0" part time and "1" full-time
                return status
            }
            
            if let statusAsInt = Int(status) {
                //when rawValue is false, if the Record object had status "0", then it will correctly return "Part-Time Employee"
                return kRecordStatusNames[statusAsInt]
            }
            else {
                return nil
            }
            
        case .WorkType:
            if rawValue {
                return type
            }
            
            if let workTypeAsInt = Int(type) {
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