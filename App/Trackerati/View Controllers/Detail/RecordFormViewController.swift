//
//  RecordFormViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class RecordFormViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var hoursTextField: UITextField!
    @IBOutlet weak var commentsTextField: UITextField!
    
    private let kCellReuseIdentifier = "cell"
    private let kCellDefaultHeight: CGFloat = 44.0
    private let record: Record
    
    private let tempRecord: Record
    
    private var infoType: RecordKey?
    
    private var activeHourPickerView: UIPickerView?
    private var activeTextField: UITextField?
    private var datePicker: UIDatePicker?
    
    private var editingForm: Bool
    private var saveOnly = false
    
    init(record: Record, editing: Bool)
    {
        editingForm = editing
        self.record = record
        tempRecord = record
        super.init(nibName: "RecordFormViewController", bundle: nil)
        title = record.date
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    convenience init(record: Record, saveOnly: Bool)
    {
        self.init(record: record, editing: true)
        self.saveOnly = saveOnly
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setNavUIToHackeratiColors()
        
        clientLabel.text = self.record.client
        projectLabel.text = self.record.project
        
        dateTextField.text = self.record.date
        dateTextField.delegate = self
        dateTextField.tintColor = UIColor.clearColor()
        dateTextField.inputView = datePickerViewForEditing()
        
        let statusRecordType = RecordKey.editableValues[RecordKeyIndex.Status.rawValue]
        statusButton.setTitle(record.valueForType(statusRecordType, rawValue: false), forState: .Normal)
        
        let worktypeRecordType = RecordKey.editableValues[RecordKeyIndex.WorkType.rawValue]
        typeButton.setTitle(record.valueForType(worktypeRecordType, rawValue: false), forState: .Normal)
        
        hoursTextField.delegate = self
        hoursTextField.tintColor = UIColor.clearColor() // hides blinking cursor
        hoursTextField.inputView = pickerViewForType(.Hours)
        
        commentsTextField.delegate = self
        
        if saveOnly {
            setupSaveButton()
        }
        else if editingForm {
            setupDoneButton()
        }
        else {
            setupEditButton()
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapToDismissKeyboard:")
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
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
    
    // MARK: UITextField Delegate methods 
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == dateTextField) {
            println("date text field")
            activeTextField = dateTextField
        }
        else if (textField == hoursTextField) {
            println("hours text field")
            activeTextField = hoursTextField
        }
        else if (textField == commentsTextField) {
            activeTextField = commentsTextField
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Picker-Views related
    
    private func datePickerViewForEditing() -> UIDatePicker
    {
        datePicker = UIDatePicker()
        datePicker!.backgroundColor = UIColor.whiteColor()
        datePicker!.datePickerMode = .Date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if let date = dateFormatter.dateFromString(record.date) {
            datePicker!.date = date
        }
        else {
            datePicker!.date = NSDate()
        }
        
        datePicker!.addTarget(self, action: "datePickerChanged:", forControlEvents: .ValueChanged)
        
        return datePicker!
    }
    
    private func pickerViewForType(cellType: RecordKey) -> UIView?
    {
        switch cellType {
            case .Hours:
                let pickerView = UIPickerView()
                pickerView.backgroundColor = UIColor.whiteColor()
                pickerView.delegate = self
                pickerView.dataSource = self
                infoType = cellType
                activeHourPickerView = pickerView
                return pickerView
            default:
                return nil
        }
    }
    
    
    // MARK: UIDatePicker Selectors
    
    @objc
    private func datePickerChanged(datePicker: UIDatePicker)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = dateFormatter.stringFromDate(datePicker.date)
    }
    
    // MARK: UIPickerView Datasource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch infoType! {
            
        case .Hours:
            return kRecordHoursNames.count
            
        default:
            return 0
        }
    }
    
    // MARK: UIPickerView Delegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let options: [String]
        let newValue: String
        switch infoType! {
        case RecordKey.Hours:
            options = kRecordHoursNames
            newValue = String(format: "%.1f", (Double(row) + 1.0) / 2.0)
            
        default:
            options = []
            newValue = ""
        }
        
        hoursTextField.text = options[row]
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let options: [String]
        switch infoType! {
        case RecordKey.Hours:
            options = kRecordHoursNames
            
        default:
            options = []
        }
        return options[row]
    }
    
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func enableEditing()
    {
        editingForm = true
        setupDoneButton()
    }
    
    @objc
    private func disableEditing()
    {
        editingForm = false
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
                    
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 2.0, customDoneText: "Completed!", completion: {
                        if let containerVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? ContainerViewController
                        {
                            containerVC.centerNavigationController.dismissViewControllerAnimated(true, completion: nil);
                        }
                    })
                })
            }
        })
    }
    
    // MARK: UIKeyboard Notification Selectors
    
//    @objc
//    private func keyboardDidShow(notification: NSNotification)
//    {
//        if let keyboardDict = notification.userInfo {
//            if let keyboardRect = keyboardDict[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
//                
//                let newContentInsets: UIEdgeInsets
//                if let navBarHeight = navigationController?.navigationBar.frame.size.height {
//                    newContentInsets = UIEdgeInsets(top: navBarHeight, left: 0.0, bottom: keyboardRect.size.height, right: 0.0)
//                }
//                else {
//                    newContentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardRect.size.height, right: 0.0)
//                }
//                
//                recordFormTableView.contentInset = newContentInsets
//                recordFormTableView.scrollIndicatorInsets = newContentInsets
//                
//                if let activeRect = activeCell?.frame {
//                    recordFormTableView.scrollRectToVisible(activeRect, animated: true)
//                }
//            }
//        }
//    }
//    
//    @objc
//    private func keyboardWillHide(notification: NSNotification)
//    {
//        if let navBarHeight = navigationController?.navigationBar.frame.size.height {
//            recordFormTableView.contentInset = UIEdgeInsets(top: navBarHeight, left: 0.0, bottom: 0.0, right: 0.0)
//            recordFormTableView.scrollIndicatorInsets = UIEdgeInsets(top: navBarHeight, left: 0.0, bottom: 0.0, right: 0.0)
//        }
//        else {
//            recordFormTableView.contentInset = UIEdgeInsetsZero
//            recordFormTableView.scrollIndicatorInsets = UIEdgeInsetsZero
//        }
//    }
//    
    
    // MARK: UIGestureRecognizer Selectors
    @objc
    private func tapToDismissKeyboard(gesture: UITapGestureRecognizer)
    {
        if activeTextField == dateTextField {
            dateTextField.resignFirstResponder()
        }
        else if activeTextField == hoursTextField  {
            hoursTextField.resignFirstResponder()
        }
        else if activeTextField == commentsTextField  {
            commentsTextField.resignFirstResponder()
        }
    }
    
}
