//
//  RecordFormViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class RecordFormViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, RecordDetailTableViewCellDelegate
{
    private let kCellReuseIdentifier = "cell"
    private let kCellDefaultHeight: CGFloat = 44.0
    private let record: Record
    
    private weak var recordFormTableView: RecordFormTableView!
    private weak var activeCell: RecordDetailTableViewCell?
    
    private var editingForm: Bool
    
    init(record: Record, editing: Bool)
    {
        editingForm = editing
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
        
        setupTableView()
        
        if editingForm {
            setupSaveButton()
        }
        else {
            setupEditButton()
        }
    }
 
    private func setupTableView()
    {
        let recordFormTableView = RecordFormTableView(frame: view.frame)
        recordFormTableView.registerClass(RecordDetailTableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        recordFormTableView.delegate = self
        recordFormTableView.dataSource = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapToDismissKeyboard:")
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1
        recordFormTableView.addGestureRecognizer(tapGestureRecognizer)
        
        view.addSubview(recordFormTableView)
        self.recordFormTableView = recordFormTableView
    }
    
    private func setupEditButton()
    {
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "enableEditing")
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupSaveButton()
    {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "saveRecord")
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func enableEditing()
    {
        editingForm = true
        for visibleCell in recordFormTableView.visibleCells()
        {
            (visibleCell as? RecordDetailTableViewCell)?.editingInfo = editingForm
        }
        setupSaveButton()
    }
    
    @objc
    private func saveRecord()
    {
        editingForm = false
        for visibleCell in recordFormTableView.visibleCells()
        {
            (visibleCell as? RecordDetailTableViewCell)?.editingInfo = editingForm
        }
        setupEditButton()
        
        // TODO: Write to Firebase
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
    
    // MARK: UIGestureRecognizer Selectors
    
    @objc
    private func tapToDismissKeyboard(gesture: UITapGestureRecognizer)
    {
        let tapLocation = gesture.locationInView(recordFormTableView)
        if let cell = activeCell {
            if !CGRectContainsPoint(cell.frame, tapLocation) {
                cell.resignFirstResponder()
            }
        }
    }
    
    // MARK: RecordDetailTableViewCell Delegate
    
    func didSelectTextFieldOnCell(cell: RecordDetailTableViewCell?) {
        activeCell = cell
    }
    
    func textFieldTextDidChangeForCell(cell: RecordDetailTableViewCell, newText: String) {
        // TODO: Enable a save button to save the changes
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
        cell.editingInfo = editingForm
        cell.delegate = self
        return cell
    }
}
