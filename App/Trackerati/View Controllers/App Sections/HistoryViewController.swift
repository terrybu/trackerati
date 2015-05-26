//
//  HistoryViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/21/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class HistoryViewController : MainViewController, UITableViewDelegate
{
    private weak var historyTableView: UITableView!
    private var historyTableViewDataSource: HistoryTableViewDataSource!
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func loadView() {
        super.loadView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "editTableView")
        
        let historyTableView = UITableView(frame: view.frame, style: .Plain)
        historyTableView.delegate = self
        historyTableViewDataSource = HistoryTableViewDataSource(tableView: historyTableView)
        historyTableView.dataSource = historyTableViewDataSource
        view.addSubview(historyTableView)
        self.historyTableView = historyTableView
    }
    
    // MARK: Private
    
    private func displayFormForRecordAtIndexPath(indexPath: NSIndexPath)
    {
        let selectedRecord = historyTableViewDataSource.recordForIndexPath(indexPath)
        navigationController?.pushViewController(RecordFormViewController(record: selectedRecord), animated: true)
    }
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func editTableView()
    {
        historyTableView.setEditing(!historyTableView.editing, animated: true)
    }
    
    // MARK: UITableView Delegate
    
    // Disables default UITableView swipe to delete. HistoryCell has own custom delete button
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .Delete
        }
        
        return .None
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! HistoryTableViewCell
        if selectedCell.currentState == .NotShowingMenu {
            displayFormForRecordAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        displayFormForRecordAtIndexPath(indexPath)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HistoryTableViewCell.cellHeight
    }
    
}
