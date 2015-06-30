//
//  FirebaseManager.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

enum DataInfoType: String
{
    case Projects = "Projects"
    case User = "Users"
}

let kUserAuthenticatedFirebaseSuccessfullyNotificationName = "userAutheticatedSuccessfully"
let kUserAuthenticatedFirebaseUnsuccessfullyNotificationName = "userAutheticatedUnsuccessfully"
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
    var userRecordsSortedByDateInTuples: [(String, [Record])]?
    var tuplesForFloatingDefaultsLabelsArray: [(String, Record)]?
    
    /*
    This array of client objects contains only clients that contain a project the user has pinned
    Additionally, the client objects ONLY contains those projects that have been pinned (others have been filtered out)
    */
    var clientsByPinnedProj: [Client]?
    
    func configureWithDatabaseURL(url: String)
    {
        assert(url != "", "Must be a valid URL")
        firebaseDB = Firebase(url: url)
    }
    
    /**
    Authenticates the logged in user with Firebase. Will fire a successful authentication notification if successful and an unsuccessful notification if not
    
    :param: token An OAuth token provided by the Google Plus API
    */
    func authenticateWithToken(token: String!)
    {
        firebaseDB.authWithOAuthProvider("google", token: token, withCompletionBlock: { error, authData in
            dispatch_async(dispatch_get_main_queue(), {
                if error != nil {
                    println(error)
                    NSNotificationCenter.defaultCenter().postNotificationName(kUserAuthenticatedFirebaseUnsuccessfullyNotificationName, object: nil)
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kUserAuthenticatedFirebaseSuccessfullyNotificationName, object: nil)
                }
            })
        })
    }
    
    /**
    Asynchronously retrieves all data associated with the type passed in. This potentially fires off three notifications. 
    
    One notification for completing the download of:
    
    - Projects
    - User records
    - Everything
    
    :param: type The type of information you want to request
    */
    func getAllDataOfType(type: DataInfoType, completion: (() -> Void)?)
    {
        self.firebaseDB.observeSingleEventOfType(.Value, withBlock: { snapshot in
            var notificationName = ""
            
            switch type {
            case .Projects:
                notificationName = kAllProjectsDownloadedNotificationName
                self.allClientProjects = self.createClientArrayFromJSON(snapshot.value, sorted: true)
                
            case .User:
                notificationName = kUserInfoDownloadedNotificationName
                self.allUserRecords = self.getRecordsForUser(snapshot.value, name: GoogleLoginManager.sharedManager.currentUser.firebaseID)
                self.userRecordsSortedByDateInTuples = self.userRecordsSortedByDate()
                self.clientsByPinnedProj = self.getClientsFilteredByPinnedProjects()
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
                
                if self.allUserRecords != nil && self.allClientProjects != nil && self.clientsByPinnedProj != nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(kAllDataDownloadedNotificationName, object: nil)
                }
                
                if let closure = completion {
                    closure()
                }
            })
        })
    
    }
    
    /**
    Sorts the User records by Date and maps the dates to an array of Record objects like so `(Date, [Record])`
    
    :returns: An array of tuples with String dates mapped to an array of Record objects that correspond to that date
    */
    func userRecordsSortedByDate() -> [(String, [Record])]
    {
        var dateToRecordDictionary: [String: [Record]] = [:]
        for record in allUserRecords! {
            if let datedRecords = dateToRecordDictionary[record.date] {
                var mutableDatedRecords = datedRecords
                mutableDatedRecords.append(record)
                dateToRecordDictionary[record.date] = mutableDatedRecords
            }
            else {
                dateToRecordDictionary[record.date] = [record]
            }
        }
        let sortedRecordsByDate = sorted(dateToRecordDictionary) { $0.0 > $1.0 }
        return sortedRecordsByDate
    }
    
    /**
    Writes the current logged in user to the list of users on a project in Firebase
    
    :param: clientName  Name of company the project belongs to
    :param: projectName Name of project within the company
    :param: completion  Completion closure once the user is deleted from Firebase
    */
    func pinCurrentUserToProject(clientName: String, projectName: String, completion:(() -> Void)?)
    {
        let projectURL = "Projects/\(clientName)/\(projectName)"
        let pinProjectRef = firebaseDB.childByAppendingPath(projectURL)
        let userToPinRef = pinProjectRef.childByAutoId()
        userToPinRef.setValue(["name": GoogleLoginManager.sharedManager.currentUser.firebaseID], withCompletionBlock: { error, firbaseRef in
            if let closure = completion {
                closure()
            }
        })
    }
    
    /**
    Removes a user from a project in Firebase
    
    :param: clientName  Name of company
    :param: projectName Name of project within the company
    :param: completion  Completion closure once the user is deleted from Firebase
    */
    func removeCurrentUserFromProject(clientName: String, projectName: String, completion:(() -> Void)?)
    {
        let projectURL = "Projects/\(clientName)/\(projectName)"
        let removeProjectRef = firebaseDB.childByAppendingPath(projectURL)
        removeProjectRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let userDictionary = snapshot.value as? NSDictionary {
                
                let keys = userDictionary.allKeys
                for key in keys {
                    
                    if let readUser = userDictionary.objectForKey(key) as? NSDictionary {
                        
                        if readUser.objectForKey("name") as! String == GoogleLoginManager.sharedManager.currentUser.firebaseID {
                            
                            let refToRemove = removeProjectRef.childByAppendingPath(key as! String)
                            refToRemove.removeValueWithCompletionBlock({ error, firebaseRef in
                                if let closure = completion {
                                    closure()
                                }
                            })
                            break
                        }
                    }
                }
            }
        })
    }
    
    //MARK: Records Saving & Deleting
    
    func saveNewRecord(record: Record, completion: ((error: NSError!) -> Void)?)
    {
        let userURL = "Users/\(GoogleLoginManager.sharedManager.currentUser.firebaseID)/records"
        
        var recordToSave: NSMutableDictionary = [:]
        for field in RecordKey.editableValues {
            if let value = record.valueForType(field, rawValue: true) {
                recordToSave.setValue(NSString(string: value), forKey: field.rawValue)
            }
        }
        println(recordToSave)
        if record.id == "" { // we're adding a new record
            let recordRef = firebaseDB.childByAppendingPath(userURL).childByAutoId()
            recordRef.setValue(recordToSave as [NSObject: AnyObject], withCompletionBlock: { error, firebaseRef in
                
                if let closure = completion {
                    closure(error: error)
                }
            })
        }
        else { // we're editing a previous record
            let recordRef = firebaseDB.childByAppendingPath(userURL).childByAppendingPath(record.id)
            recordRef.updateChildValues(recordToSave as [NSObject : AnyObject], withCompletionBlock: { error, firebaseRef in
                println("updating child values completed \(firebaseRef.key)")
                if let closure = completion {
                    closure(error: error)
                }
            })
        }
    }
    
    func deleteRecord(record: Record, completion: ((error: NSError!) -> Void)?)
    {
        let userURL = "Users/\(GoogleLoginManager.sharedManager.currentUser.firebaseID)/records"
        let recordRef = firebaseDB.childByAppendingPath(userURL + "/" + record.id)
        recordRef.removeValueWithCompletionBlock { error, firebaseRef in
            if let closure = completion {
                closure(error: error)
            }
        }
    }
    

    func saveSelectedDefaultRecord(pastRecord: Record, completion:((error: NSError!) -> Void)?) {
        
        var newRecord = Record(client: pastRecord.client, project: pastRecord.project)
        newRecord.hours = pastRecord.hours
        newRecord.type = pastRecord.type
        newRecord.status = pastRecord.status
        
        //Date is the only one that's different for this default record selection from floating action buttons
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var todaysDate = dateFormatter.stringFromDate(NSDate())
        newRecord.date = todaysDate
        
        saveNewRecord(newRecord, completion: { (error) -> Void in
            if (error != nil) {
                println(error)
            }
            else {
                self.getAllDataOfType(DataInfoType.User, completion: { () -> Void in
                    if let closure = completion {
                        closure(error: error)
                    }
                })
            }
        })
    }
    
    
    // MARK: Projects Saving & Deleting & Filtering
    
    func saveNewProject (clientString: String, projectString: String, completion: ((error: NSError!, duplicateFound: Bool) -> Void)?)
    {
        if (validateProjectNameBeforeSendingToFirebase(clientString, projectString: projectString)) {
            let newProjectURL = "Projects/\(clientString)/\(projectString)"
            let newProjectRef = firebaseDB.childByAppendingPath(newProjectURL)
            newProjectRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if (snapshot.value != nil && snapshot.hasChildren()) {
                    //if we got data back from firebase at that URL, client/project name already exists, don't write
                    if let closure = completion {
                        closure(error: nil, duplicateFound: true)
                    }
                }
                else {
                    //safe to write
                    let newProjectRefWithID = newProjectRef.childByAutoId()
                    let placeHolder = [ "name" : "placeholder" ]
                    newProjectRefWithID.setValue(placeHolder as [NSObject: AnyObject], withCompletionBlock: { error, firebaseRef in
                        
                        if error == nil {
                            FirebaseManager.sharedManager.getAllDataOfType(.Projects, completion: { () -> Void in
                                if let closure = completion {
                                    closure(error: error, duplicateFound: false)
                                }
                            })
                        }
                        else {
                            if let closure = completion {
                                closure(error: error, duplicateFound: false)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func deleteProject (clientName: String, projectName: String, completion: ((error: NSError!) -> Void)?) {
        let userURL = "Projects/\(clientName)/\(projectName)"
        let recordRef = firebaseDB.childByAppendingPath(userURL)
        recordRef.removeValueWithCompletionBlock { error, firebaseRef in
            if let closure = completion {
                closure(error: error)
            }
        }
    }
    
    func validateProjectNameBeforeSendingToFirebase(clientString: String, projectString: String) -> Bool {
        //Extra validation if we want to --> lowercase/uppercase check ex) prevent "hackerati" vs "Hackerati"
        return true
    }
    
    func returnThreeLatestUniqueClientProjectsFromUserRecords() -> [(String, Record)] {
        
        var threeUniqueProjectNamesSet = NSMutableOrderedSet()
        var resultsTuplesArray = [(String, Record)]()
        
        for i in 0..<self.userRecordsSortedByDateInTuples!.count {
            var currentTuple = self.userRecordsSortedByDateInTuples![i]
            for record:Record in currentTuple.1 {
                if threeUniqueProjectNamesSet.count >= 3 {
                    break
                }
                var newString = "\(record.client)" + ": \(record.project)"
                if !threeUniqueProjectNamesSet.containsObject(newString) {
                    threeUniqueProjectNamesSet.addObject(newString)
                    resultsTuplesArray.append((newString, record))
                }
            }
        }
        
        return resultsTuplesArray
    }
    
    func findRecordThatCorrespondsToFloatingCell(string: String, indexPath: NSIndexPath) -> Record? {
        
        if (tuplesForFloatingDefaultsLabelsArray != nil) && (indexPath.row < tuplesForFloatingDefaultsLabelsArray!.count) {
            if let tuple = tuplesForFloatingDefaultsLabelsArray![indexPath.row] as? (String, Record)  {
                return tuple.1
            }
        }
        return nil
    }
    
    
    
    
    // MARK: Private
    
    private func getRecordsForUser(json: AnyObject, name: String) -> [Record]
    {
        var records = [Record]()
        let firebaseUsername = GoogleLoginManager.sharedManager.currentUser.firebaseID
        
        if let dataDictionary = json as? NSDictionary {
            
            if let users = dataDictionary.objectForKey(DataInfoType.User.rawValue) as? NSDictionary { // get dictionary of all users
                
                if let loggedInUserInfo = users.objectForKey(firebaseUsername) as? NSDictionary { // get dictionary associated with loggin in user
                    
                    if let recordsKey = loggedInUserInfo.allKeys.first as? String { // get the key, "records", for getting dictionary of all of the user's records
                        
                        if let firebaseRecords = loggedInUserInfo.objectForKey(recordsKey) as? NSDictionary { // get dictionary of all records for user
                            
                            for recordKey in firebaseRecords.allKeys { // loop through all hashes
                                
                                if let recordDictionary = firebaseRecords.objectForKey(recordKey) as? NSDictionary { // get dictionary for individual record for specific hash
                                    
                                    let id = recordKey as! String
                                    let client = recordDictionary.objectForKey(RecordKey.Client.rawValue) as! String
                                    let date = recordDictionary.objectForKey(RecordKey.Date.rawValue) as! String
                                    let hours = recordDictionary.objectForKey(RecordKey.Hours.rawValue) as! String
                                    let project = recordDictionary.objectForKey(RecordKey.Project.rawValue) as! String
                                    let status = recordDictionary.objectForKey(RecordKey.Status.rawValue) as! String
                                    let type = recordDictionary.objectForKey(RecordKey.WorkType.rawValue) as! String
                                    let comment = recordDictionary.objectForKey(RecordKey.Comment.rawValue) as? String
                                    let newRecord = Record(id: id, client: client, date: date, hours: hours, project: project, status: status, type: type, comment: comment)
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
    
    private func createClientArrayFromJSON(json: AnyObject, sorted: Bool) -> [Client]
    {
        let dataDictionary = json as! NSDictionary
        let projects = dataDictionary.objectForKey(DataInfoType.Projects.rawValue) as! NSDictionary
        var clients: [Client] = []
        
        for key in projects.allKeys {
            let clientName = key as! String
            let projectDetails = projects.objectForKey(key) as! NSDictionary
            
            var projects: [Project] = []
            for projectName in projectDetails.allKeys as! [String] {
                var usersForProject: [String] = []
                if let projectUsers = projectDetails.objectForKey(projectName) as? NSDictionary {
                    for userKey in projectUsers.allKeys {
                        // Gotta get another stupid dictionary to index into for the names of users...
                        if let userDictionary = projectUsers.objectForKey(userKey) as? NSDictionary, let userFirebaseID = userDictionary.objectForKey("name") as? String {
                            if userFirebaseID != "placeholder" {
                                usersForProject.append(userFirebaseID)
                            }
                        }
                    }
                }
                
                let newProject = Project(name: projectName, users: usersForProject)
                projects.append(newProject)
            }
            
            let newClient = Client(companyName: clientName, projects: projects)
            clients.append(newClient)
        }
        
        if sorted {
            clients.sort({ $0.companyName.uppercaseString < $1.companyName.uppercaseString })
        }
        
        return clients
    }
    
    /**
    This method creates an array of client objects with only partial project arrays within them.
    The projects in those array are the one's that the user has pinned.
    */
    
    private func getClientsFilteredByPinnedProjects() -> [Client]
    {
        var pinnedProjects: [Client] = []
        for client in allClientProjects! {
            let newProjectArray = client.projects.filter({ contains($0.users, GoogleLoginManager.sharedManager.currentUser.firebaseID) })
            if newProjectArray.count > 0 {
                let pinnedClient = Client(companyName: client.companyName, projects: newProjectArray)
                pinnedProjects.append(pinnedClient)
            }
        }
        
        return pinnedProjects
    }
    
}
