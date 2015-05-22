//
//  HistoryViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/21/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class HistoryViewController : MainViewController, UITableViewDelegate, UITableViewDataSource
{
    private let kCellReuseIdentifier = "cell"
    
    private weak var historyTableView: UITableView!
    private var userHistory: [(String, [Record])] = []
    
    init(userHistory: [(String, [Record])]?)
    {
        super.init(nibName: nil, bundle: nil)
        if let history = userHistory {
            self.userHistory = history
        }
        else {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.labelText = "Just a moment"
            hud.detailsLabelText = "Going through the file cabinets"
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "historyFinishedDownloading:", name: kAllProjectsDownloadedNotificationName, object: nil)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func loadView() {
        super.loadView()
        
        let historyTableView = UITableView(frame: view.frame, style: .Plain)
        historyTableView.registerClass(HistoryTableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        historyTableView.delegate = self
        historyTableView.dataSource = self
        view.addSubview(historyTableView)
        self.historyTableView = historyTableView
    }
    
    // MARK: Private
    
    private func recordForIndexPath(indexPath: NSIndexPath) -> Record
    {
        return userHistory[indexPath.section].1[indexPath.row]
    }
    
    private func displayFormForRecordAtIndexPath(indexPath: NSIndexPath)
    {
        let selectedRecord = recordForIndexPath(indexPath)
        navigationController?.pushViewController(RecordFormViewController(record: selectedRecord), animated: true)
    }
    
    // MARK: NSNotificationCenter Observer Methods
    
    @objc
    private func historyFinishedDownloading(notification: NSNotification)
    {
        userHistory = FirebaseManager.sharedManager.userRecordsSortedByDate()
        
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        historyTableView.reloadData()
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        displayFormForRecordAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        displayFormForRecordAtIndexPath(indexPath)
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HistoryTableViewCell.cellHeight
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
