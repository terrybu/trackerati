//
//  HistoryViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/21/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

private let kCellReuseIdentifier = "HistoryTableViewCell"

class HistoryViewController : MainViewController, UITableViewDelegate, UITableViewDataSource, HistoryTableViewCellDelegate
{
    private var historyTableView: UITableView!
    var userHistory: [(String, [Record])] = []

    override func loadView() {
        super.loadView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "editTableView")
        setNavUIToHackeratiColors()
        setupTableView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userRecordsRedownloaded", name: kUserInfoDownloadedNotificationName, object: nil)
    }
    
    // MARK: Private
    private func setupTableView() {
        userHistory = FirebaseManager.sharedManager.userRecordsSortedByDateInTuples!
        historyTableView = UITableView(frame: view.frame, style: .Plain)
        historyTableView.registerClass(HistoryTableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        historyTableView.delegate = self
        historyTableView.dataSource = self
        view.addSubview(historyTableView)
    }
    
    @objc
    private func userRecordsRedownloaded() {
        userHistory = FirebaseManager.sharedManager.userRecordsSortedByDateInTuples!
        historyTableView.reloadData()
    }
    
    
    private func displayFormForRecordAtIndexPath(indexPath: NSIndexPath, editing: Bool)
    {
        let selectedRecord = recordForIndexPath(indexPath)
        
        if let containerVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? ContainerViewController
        {
            let recordForm = RecordFormViewController(record: selectedRecord)
            recordForm.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismissForm")
            recordForm.title = selectedRecord.date
            let newFormNavController = UINavigationController(rootViewController: recordForm)
            containerVC.centerNavigationController.presentViewController(newFormNavController, animated: true, completion: nil)
        }
    }
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func editTableView()
    {
        historyTableView.setEditing(!historyTableView.editing, animated: true)
    }
    
    @objc
    private func dismissForm()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        view.tintColor = UIColor(rgba: "#2D2D2D")
        header.textLabel!.textColor = UIColor.whiteColor()
//        header.textLabel.font = UIFont.boldSystemFontOfSize(25)
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Set delegate of cell here since datasource is separated out
        (cell as? HistoryTableViewCell)?.delegate = self
    }
    
    // Disables default UITableView swipe to delete. HistoryCell has own custom delete button
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .Delete
        }
        
        return .None
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! HistoryTableViewCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //The reason that history tableview cells don't light up upon touch is as follows:
        //HistoryTableViewCell's selection style is intentionally set to None
        //if we light up the cell based on touch, those clear buttons get exposed against the gray background
        //if we try to hide those two buttons initially, there's no easy way to hide them again after the user engages in swipe motion
        //leave it for now. see if this is actually a ux problem before trying to fix

        if cell.currentState == .NotShowingMenu {
            displayFormForRecordAtIndexPath(indexPath, editing: false)
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HistoryTableViewCell.cellHeight
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteRecordFromFirebaseDataAndViewAtIndexPath(indexPath);
        }
    }
    
    func deleteRecordFromFirebaseDataAndViewAtIndexPath(indexPath: NSIndexPath) {
        let deleteThisRecord = recordForIndexPath(indexPath) //point to it before you lose it in userHistory
        
        //we delete from firebase first
        //then we delete local record object from firebase singleton instance
        FirebaseManager.sharedManager.deleteRecord(deleteThisRecord, completion: { (error) -> Void in
            FirebaseManager.sharedManager.userRecordsSortedByDateInTuples![indexPath.section].1.removeAtIndex(indexPath.row)
            if (FirebaseManager.sharedManager.userRecordsSortedByDateInTuples![indexPath.section].1.isEmpty) {
                FirebaseManager.sharedManager.userRecordsSortedByDateInTuples!.removeAtIndex(indexPath.section)
            }
            //then we also delete record object from this vc
            self.userHistory[indexPath.section].1.removeAtIndex(indexPath.row)
            if (self.userHistory[indexPath.section].1.isEmpty) {
                self.userHistory.removeAtIndex(indexPath.section);
                self.historyTableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic);
            }
            else {
                self.historyTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        })
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
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        //        cell.deleteButton.hidden = true
        //        cell.editButton.hidden = true
        
        return cell
    }

    func recordForIndexPath(indexPath: NSIndexPath) -> Record
    {
        return userHistory[indexPath.section].1[indexPath.row]
    }
    
    
    
    // MARK: HistoryTableViewCell Delegate
    
    func didPressDeleteButton(cell: HistoryTableViewCell) {
        if let cellIndexPath = self.historyTableView.indexPathForCell(cell) {
            deleteRecordFromFirebaseDataAndViewAtIndexPath(cellIndexPath);
        }
    }
    
    func didPressEditButton(cell: HistoryTableViewCell) {
        if let cellIndexPath = self.historyTableView.indexPathForCell(cell) {
            displayFormForRecordAtIndexPath(cellIndexPath, editing: true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
