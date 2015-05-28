//
//  RecordFormViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class RecordFormViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private let kCellReuseIdentifier = "cell"
    private let kCellDefaultHeight: CGFloat = 44.0
    private let record: Record
    
    private weak var recordFormTableView: RecordFormTableView!
    private weak var activeCell: RecordDetailTableViewCell?
    
    init(record: Record, editing: Bool)
    {
        self.record = record
        super.init(nibName: nil, bundle: nil)
        title = record.date
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        
        let recordFormTableView = RecordFormTableView(frame: view.frame)
        recordFormTableView.registerClass(RecordDetailTableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        recordFormTableView.delegate = self
        recordFormTableView.dataSource = self
        view.addSubview(recordFormTableView)
        self.recordFormTableView = recordFormTableView
    }
 
    // MARK: UIKeyboard Notification Selectors
    
    @objc
    private func keyboardDidShow(notification: NSNotification)
    {
        if let keyboardDict = notification.userInfo {
            if let keyboardRect = keyboardDict[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
                
                let newContentInsets: UIEdgeInsets
                if let navBarHeight = navigationController?.navigationBar.frame.size.height {
                    newContentInsets = UIEdgeInsets(top: navBarHeight, left: 0.0, bottom: keyboardRect.size.height, right: 0.0)
                }
                else {
                    newContentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardRect.size.height, right: 0.0)
                }
                
                recordFormTableView.contentInset = newContentInsets
                recordFormTableView.scrollIndicatorInsets = newContentInsets
                
                if let activeRect = activeCell?.frame {
                    recordFormTableView.scrollRectToVisible(activeRect, animated: true)
                }
            }
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification)
    {
        if let navBarHeight = navigationController?.navigationBar.frame.size.height {
            recordFormTableView.contentInset = UIEdgeInsets(top: navBarHeight, left: 0.0, bottom: 0.0, right: 0.0)
            recordFormTableView.scrollIndicatorInsets = UIEdgeInsets(top: navBarHeight, left: 0.0, bottom: 0.0, right: 0.0)
        }
        else {
            recordFormTableView.contentInset = UIEdgeInsetsZero
            recordFormTableView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activeCell = tableView.cellForRowAtIndexPath(indexPath) as? RecordDetailTableViewCell
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kCellDefaultHeight
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return RecordKey.editableValues[section].rawValue.capitalizedString
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Record.numberOfFields
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! RecordDetailTableViewCell
        let recordType = RecordKey.editableValues[indexPath.section]
        cell.information = record.valueForType(recordType)
        cell.infoType = recordType
        return cell
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch, let cell = activeCell {
            if cell.isFirstResponder() && touch.view != cell {
                cell.endEditing(true)
            }
        }
    }
    
}
