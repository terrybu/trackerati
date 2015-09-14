//
//  HistoryViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/21/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class HistoryViewController : MainViewController, UITableViewDelegate, HistoryTableViewCellDelegate
{
    private weak var historyTableView: UITableView!
    private var historyTableViewDataSource: HistoryTableViewDataSource!
    
    override func loadView() {
        super.loadView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "editTableView")
        setNavUIToHackeratiColors()
        setupTableView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userRecordsRedownloaded", name: kUserInfoDownloadedNotificationName, object: nil)
    }
    
    // MARK: Private
    private func setupTableView() {
        let historyTableView = UITableView(frame: view.frame, style: .Plain)
        historyTableView.delegate = self
        historyTableView.dataSource = HistoryTableViewDataSource(tableView: historyTableView)
        self.historyTableView = historyTableView
        view.addSubview(self.historyTableView)
    }
    
    @objc
    private func userRecordsRedownloaded() {
        historyTableViewDataSource.userHistory = FirebaseManager.sharedManager.userRecordsSortedByDateInTuples!
        self.historyTableView.reloadData()
    }
    
    
    private func displayFormForRecordAtIndexPath(indexPath: NSIndexPath, editing: Bool)
    {
        let selectedRecord = historyTableViewDataSource.recordForIndexPath(indexPath)
        
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
    
    // MARK: HistoryTableViewCell Delegate
    
    func didPressDeleteButton(cell: HistoryTableViewCell) {
        if let cellIndexPath = self.historyTableView.indexPathForCell(cell) {
            historyTableViewDataSource.deleteRecordFromFirebaseDataAndViewAtIndexPath(cellIndexPath);
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
