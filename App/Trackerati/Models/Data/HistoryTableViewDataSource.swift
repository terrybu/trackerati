//
//  HistoryTableViewDataSource.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//


//import Foundation
//
///// This class is no longer used as of 9/14/2015. After changing to iOS9, our original code had some problem calling this data source from outside of the HistoryViewController so all the below code made its way back into the view controller
//
//class HistoryTableViewDataSource : NSObject, UITableViewDataSource
//{
//    private let kCellReuseIdentifier = "HistoryTableViewCell"
//    
//    private weak var tableView: UITableView!
//    var userHistory: [(String, [Record])] = []
//    
//    init(tableView: UITableView)
//    {
//        super.init()
//        self.tableView = tableView
//        self.tableView.registerClass(HistoryTableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
//        userHistory = FirebaseManager.sharedManager.userRecordsSortedByDateInTuples!
//    }
//    
//    func recordForIndexPath(indexPath: NSIndexPath) -> Record
//    {
//        return userHistory[indexPath.section].1[indexPath.row]
//    }
//    
//    // MARK: UITableView Datasource
//    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            deleteRecordFromFirebaseDataAndViewAtIndexPath(indexPath);
//        }
//    }
//    
//    func deleteRecordFromFirebaseDataAndViewAtIndexPath(indexPath: NSIndexPath) {
//        let deleteThisRecord = recordForIndexPath(indexPath) //point to it before you lose it in userHistory
//        
//        //we delete from firebase first
//        //then we delete local record object from firebase singleton instance
//        FirebaseManager.sharedManager.deleteRecord(deleteThisRecord, completion: { (error) -> Void in
//            FirebaseManager.sharedManager.userRecordsSortedByDateInTuples![indexPath.section].1.removeAtIndex(indexPath.row)
//            if (FirebaseManager.sharedManager.userRecordsSortedByDateInTuples![indexPath.section].1.isEmpty) {
//                FirebaseManager.sharedManager.userRecordsSortedByDateInTuples!.removeAtIndex(indexPath.section)
//            }
//            //then we also delete record object from this vc
//            self.userHistory[indexPath.section].1.removeAtIndex(indexPath.row)
//            if (self.userHistory[indexPath.section].1.isEmpty) {
//                self.userHistory.removeAtIndex(indexPath.section);
//                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic);
//            }
//            else {
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            }
//        })
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return userHistory.count
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return userHistory[section].1.count
//    }
//    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return userHistory[section].0
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! HistoryTableViewCell
//        cell.setValuesForRecord(recordForIndexPath(indexPath))
//        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//        
////        cell.deleteButton.hidden = true
////        cell.editButton.hidden = true
//        
//        return cell
//    }
//    
//}
