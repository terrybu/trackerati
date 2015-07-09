//
//  LastSavedManager.swift
//  Trackerati
//
//  Created by Terry Bu on 7/8/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class LastSavedManager {
    
    class var sharedManager : LastSavedManager {
        struct Static {
            static var instance : LastSavedManager?
            static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = LastSavedManager()
        }
        return Static.instance!
    }
    
    func getLastSavedRecordsArrayFromDefaults() -> NSMutableArray? {
        var data = NSUserDefaults.standardUserDefaults().dataForKey(kLastSavedRecord)
        if let recordsArrayData = data {
            var unarchivedRecordsArray: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(recordsArrayData)
            return unarchivedRecordsArray as? NSMutableArray
        }
        return nil
    }
    
    func getRecordForClient(clientString: String, projectString: String) -> Record? {
        var resultRecord = Record?()
        var array = getLastSavedRecordsArrayFromDefaults()
        if let lastRecordsArray = array {
            lastRecordsArray.enumerateObjectsUsingBlock({ (object: AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                var thisRecord = object as! Record
                println("\(thisRecord.client) \(thisRecord.project)")
                if thisRecord.client == clientString && thisRecord.project == projectString {
                    resultRecord = thisRecord
                    var shouldStop: ObjCBool = true
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
            
            var recordsToDelete = NSMutableArray()
            for aRecord in lastSavedArray {
                var oldRecord = aRecord as! Record
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
        var archivedData = NSKeyedArchiver.archivedDataWithRootObject(lastSavedRecordsArray!)
        defaults.setObject(archivedData, forKey: kLastSavedRecord)
        defaults.synchronize()
    }
    
    
    
}