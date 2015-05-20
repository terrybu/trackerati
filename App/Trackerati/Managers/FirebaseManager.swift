//
//  FirebaseManager.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

enum DataInfoType: String
{
    case Projects = "Projects"
    case User = "Users"
}

enum RecordKey: String
{
    case Client = "client"
    case Date = "date"
    case Hours = "hour"
    case Project = "project"
    case Status = "status"
    case WorkType = "type"
}

let kAllDataDownloadedNotificationName = "allDataDownloaded"
let kUserInfoDownloadedNotificationName = "userInfoDownloaded"
let kAllProjectsDownloadedNotificationName = "allProjectsDownloaded"

let kNotificationDownloadedInfoKey = "downloadedData"

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
    
    var allClientProjects: [Client]?
    var allUserRecords: [Record]?
    
    func configureWithDatabaseURL(url: String)
    {
        assert(url != "", "Must be a valid URL")
        firebaseDB = Firebase(url: url)
    }
    
    func getAllDataOfType(type: DataInfoType)
    {
        self.firebaseDB.observeSingleEventOfType(.Value, withBlock: { snapshot in
            var notificationName = ""
            var downloadedData = []
            
            switch type {
            case .Projects:
                notificationName = kAllProjectsDownloadedNotificationName
                if self.allClientProjects == nil {
                    self.allClientProjects = self.createClientArrayFromJSON(snapshot.value, sorted: true)
                }
                downloadedData = self.allClientProjects!
                
            case .User:
                notificationName = kUserInfoDownloadedNotificationName
                if self.allUserRecords == nil {
                    self.allUserRecords = self.getRecordsForUser(snapshot.value, name: TrackeratiUserDefaults.standardDefaults.currentUser())
                }
                
                downloadedData = self.allUserRecords!
            }

            
            dispatch_async(dispatch_get_main_queue(), {
                let userInfo = [kNotificationDownloadedInfoKey: downloadedData]
                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: userInfo)
                
                if self.allUserRecords != nil && self.allClientProjects != nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(kAllDataDownloadedNotificationName, object: nil, userInfo: nil)
                }
            })
        })
    }
    
    func userRecordsSortedByDate() -> [String: [Record]]
    {
        var dateToRecordDictionary: [String: [Record]] = [:]
        for record in allUserRecords! {
            if let datedRecords = dateToRecordDictionary[record.date] {
                var mutableDatedRecords = datedRecords
                mutableDatedRecords.append(record)
            }
            else {
                dateToRecordDictionary[record.date] = [record]
            }
        }
        println(dateToRecordDictionary)
        return dateToRecordDictionary
    }
    
    private func getRecordsForUser(json: AnyObject, name: String) -> [Record]
    {
        var records = [Record]()
        let unwantedCharacters = NSCharacterSet(charactersInString: "@.")
        let firebaseUsername = join("", name.componentsSeparatedByCharactersInSet(unwantedCharacters))
        if let dataDictionary = json as? NSDictionary {
            
            if let users = dataDictionary.objectForKey(DataInfoType.User.rawValue) as? NSDictionary { // get dictionary of all users
                
                if let loggedInUserInfo = users.objectForKey(firebaseUsername) as? NSDictionary { // get dictionary associated with loggin in user
                    
                    if let recordsKey = loggedInUserInfo.allKeys.first as? String { // get the key, "records", for getting dictionary of all of the user's records
                        
                        if let firebaseRecords = loggedInUserInfo.objectForKey(recordsKey) as? NSDictionary { // get dictionary of all records for user
                            
                            for recordKey in firebaseRecords.allKeys { // loop through all hashes
                                
                                if let recordDictionary = firebaseRecords.objectForKey(recordKey) as? NSDictionary { // get dictionary for individual record for specific hash
                                    
                                    let client = recordDictionary.objectForKey(RecordKey.Client.rawValue) as! String
                                    let date = recordDictionary.objectForKey(RecordKey.Date.rawValue) as! String
                                    let hours = recordDictionary.objectForKey(RecordKey.Hours.rawValue) as! String
                                    let project = recordDictionary.objectForKey(RecordKey.Project.rawValue) as! String
                                    let status = recordDictionary.objectForKey(RecordKey.Status.rawValue) as! String
                                    let type = recordDictionary.objectForKey(RecordKey.WorkType.rawValue) as! String
                                    let newRecord = Record(client: client, date: date, hours: hours, project: project, status: status, type: type)
                                    records.append(newRecord)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return records
    }
    
    // MARK: Private
    
    private func createClientArrayFromJSON(json: AnyObject, sorted: Bool) -> [Client]
    {
        let dataDictionary = json as! NSDictionary
        let projects = dataDictionary.objectForKey(DataInfoType.Projects.rawValue) as! NSDictionary
        var clients = [Client]()
        
        for key in projects.allKeys {
            let clientName = key as! String
            let projectDetails = projects.objectForKey(key) as! NSDictionary
            let clientProjects = projectDetails.allKeys as! [String]
            let newClient = Client(companyName: clientName, projectNames: clientProjects)
            clients.append(newClient)
        }
        
        if sorted {
            clients.sort({ $0.companyName.uppercaseString < $1.companyName.uppercaseString })
        }
        
        return clients
    }
    
}
