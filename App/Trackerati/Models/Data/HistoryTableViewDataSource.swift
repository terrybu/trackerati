//
//  HistoryTableViewDataSource.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

class HistoryTableViewDataSource : NSObject, UITableViewDataSource
{
    private let kCellReuseIdentifier = "cell"
    
    private weak var tableView: UITableView!
    private var userHistory: [(String, [Record])] = []
    
    init(tableView: UITableView)
    {
        super.init()
        self.tableView = tableView
        self.tableView.registerClass(HistoryTableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        
        userHistory = FirebaseManager.sharedManager.userRecordsSortedByDate()
    }
    
    func recordForIndexPath(indexPath: NSIndexPath) -> Record
    {
        return userHistory[indexPath.section].1[indexPath.row]
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // TODO: Delete cell and record from Firebase
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return userHistory.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userHistory[section].1.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return userHistory[section].0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! HistoryTableViewCell
        cell.setValuesForRecord(recordForIndexPath(indexPath))
        return cell
    }
    
}
