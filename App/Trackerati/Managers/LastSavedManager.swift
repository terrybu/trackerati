//
//  LastSavedManager.swift
//  Trackerati
//
//  Created by Terry Bu on 7/8/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class LastSavedManager {
    
    static let sharedManager = LastSavedManager()
    
    func getLastSavedRecordsArrayFromDefaults() -> NSMutableArray? {
        let data = NSUserDefaults.standardUserDefaults().dataForKey(kLastSavedRecord)
        if let recordsArrayData = data {
            let unarchivedRecordsArray: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(recordsArrayData)
            return unarchivedRecordsArray as? NSMutableArray
        } else {
            print("no data was found for key lastsavedrecord in user defaults")
        }
        return nil
    }
    
    func getRecordForClient(clientString: String, projectString: String) -> Record? {
        var resultRecord = Record?()
        let array = getLastSavedRecordsArrayFromDefaults()
        if let lastRecordsArray = array {
            lastRecordsArray.enumerateObjectsUsingBlock({ (object: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let thisRecord = object as! Record
//                println("\(thisRecord.client) \(thisRecord.project)")
                if thisRecord.client == clientString && thisRecord.project == projectString {
                    resultRecord = thisRecord
                    let shouldStop: ObjCBool = true
                    stop.initialize(shouldStop)
                }
            })
        }
        if let result = resultRecord {
            return result
        }
        return nil
    }
    
    
    func saveRecordForLastSavedRecords(record: Record) {
        var lastSavedRecordsArray = getLastSavedRecordsArrayFromDefaults()
        if let lastSavedArray = lastSavedRecordsArray {
            //if the saved info array already had Records, check each record's client names and project names Ex) Hackerati, Internal. If matched, we remove that record and replace it with a new record last saved information
            
            let recordsToDelete = NSMutableArray()
            for aRecord in lastSavedArray {
                let oldRecord = aRecord as! Record
                if oldRecord.client == record.client && oldRecord.project == record.project {
                    recordsToDelete.addObject(oldRecord)
                }
            }
            //this recordsToDelete logic is needed because we can't remove objects frmo mutableLastSavedArray while iterating
            if recordsToDelete.count > 0 {
                lastSavedRecordsArray?.removeObjectsInArray(recordsToDelete as [AnyObject])
            }
            lastSavedRecordsArray?.addObject(record)
            
        }
        else {
            //there was no data in lastSavedRecords
            //make a new array
            lastSavedRecordsArray = [record]
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        let archivedData = NSKeyedArchiver.archivedDataWithRootObject(lastSavedRecordsArray!)
        defaults.setObject(archivedData, forKey: kLastSavedRecord)
        defaults.synchronize()
    }
    
    //this was when I was thinking that notifications should be based on last saved record.
    //changed my mind, just using latest record from firebase
//    func getLastRecordForActionableNotification() -> Record? {
//        var lastSavedRecords = getLastSavedRecordsArrayFromDefaults()
//        if let lastSavedRecords = lastSavedRecords {
//            for object in lastSavedRecords {
//                println(object.project)
//            }
//            let lastRecord = lastSavedRecords.lastObject as! Record
//            return lastRecord
//        } else {
//            println("last saved records array from user defaults was never found")
//        }
//        return nil
//    }
    
}