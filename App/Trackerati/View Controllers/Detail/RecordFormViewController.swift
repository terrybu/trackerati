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
    private let tempRecord: Record
    
    private weak var recordFormTableView: RecordFormTableView!
    private weak var activeCell: RecordDetailTableViewCell?
    
    private var editingForm: Bool
    private var saveOnly = false
    
    init(record: Record, editing: Bool)
    {
        editingForm = editing
        self.record = record
        tempRecord = record
        super.init(nibName: nil, bundle: nil)
        title = record.date
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    convenience init(record: Record, saveOnly: Bool)
    {
        self.init(record: record, editing: true)
        self.saveOnly = saveOnly
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        
        setupTableView()
        
        if saveOnly {
            setupSaveButton()
        }
        else if editingForm {
            setupDoneButton()
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
    
    private func setupDoneButton()
    {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "disableEditing")
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func setupSaveButton()
    {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveRecord")
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
        setupDoneButton()
    }
    
    @objc
    private func disableEditing()
    {
        editingForm = false
        for visibleCell in recordFormTableView.visibleCells()
        {
            (visibleCell as? RecordDetailTableViewCell)?.resignFirstResponder()
            (visibleCell as? RecordDetailTableViewCell)?.editingInfo = editingForm
        }
        setupEditButton()
    }
    
    @objc
    private func saveRecord()
    {
        disableEditing()
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Saving Record"
        FirebaseManager.sharedManager.saveNewRecord(tempRecord, completion: { error in
            if error == nil {
                FirebaseManager.sharedManager.getAllDataOfType(.User, completion: {
                    
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 2.0, completion: {
                        if let containerVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? ContainerViewController
                        {
                            containerVC.centerNavigationController.popViewControllerAnimated(true)
                        }
                    })
                })
            }
        })
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
        
        if tempRecord.valueForType(cell.infoType, rawValue: false) != newText {
            setupSaveButton()
            
            switch cell.infoType! {
            case .Date:
                tempRecord.date = newText
            case .Hours:
                tempRecord.hours = newText
            case .Status:
                tempRecord.status = newText
            case .WorkType:
                tempRecord.type = newText
            case .Comment:
                tempRecord.comment = newText
            default:
                break
            }
        }
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
        cell.information = record.valueForType(recordType, rawValue: false)
        cell.infoType = recordType
        cell.editingInfo = editingForm
        cell.delegate = self
        return cell
    }
}
