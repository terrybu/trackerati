//
//  RecordFormViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class RecordFormViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, THDatePickerDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    

    @IBOutlet weak var hoursTextField: UITextField!
    @IBOutlet weak var commentsTextField: UITextField!
    
    @IBOutlet weak var saveRecordButton: UIButton!

    
    private let kCellReuseIdentifier = "cell"
    private let kCellDefaultHeight: CGFloat = 44.0
    private let record: Record
    
    private let tempRecord: Record
    
    private var infoType: RecordKey?
    
    private var activeHourPickerView: UIPickerView?
    private var activeTextField: UITextField?
    private var datePicker: UIDatePicker?
    
    private var editingForm: Bool
    private var saveOnlyFormForAddingNewRecord = false
    
    init(record: Record, editing: Bool)
    {
        editingForm = editing
        self.record = record
        tempRecord = record
        super.init(nibName: "RecordFormViewController", bundle: nil)
        title = record.date
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    convenience init(record: Record, saveOnlyFormForAddingNewRecord: Bool)
    {
        self.init(record: record, editing: true)
        self.saveOnlyFormForAddingNewRecord = saveOnlyFormForAddingNewRecord
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
        dateTextField.inputView = nil
        
        
        let statusRecordType = RecordKey.editableValues[RecordKeyIndex.Status.rawValue]
        if saveOnlyFormForAddingNewRecord {
            //if its a whole new form for a new record, we are going to use our saved employment defaults
            let savedEmploymentStatus = TrackeratiUserDefaults.standardDefaults.getEmploymentStatus()
            record.status = "\(savedEmploymentStatus.rawValue)"
        }
        statusButton.setTitle(record.valueForType(statusRecordType, rawValue: false), forState: .Normal)
        
        let worktypeRecordType = RecordKey.editableValues[RecordKeyIndex.WorkType.rawValue]
        typeButton.setTitle(record.valueForType(worktypeRecordType, rawValue: false), forState: .Normal)
        
        hoursTextField.text = record.hours
        hoursTextField.delegate = self
        hoursTextField.tintColor = UIColor.clearColor() // hides blinking cursor
        hoursTextField.inputView = pickerViewForType(.Hours)
        
        commentsTextField.delegate = self
        commentsTextField.text = record.comment
        if record.comment == nil || record.comment == "" {
            commentsTextField.placeholder = nil
        }
        
        if saveOnlyFormForAddingNewRecord {
            //Last Saved Manager into play
            var lastSavedData = LastSavedManager.sharedManager.getRecordForClient(self.record.client, projectString: self.record.project)
            if let lastSavedRecordForProject = lastSavedData {
                println(lastSavedRecordForProject)
                record.type = lastSavedRecordForProject.type
                typeButton.setTitle(record.valueForType(worktypeRecordType, rawValue: false), forState: .Normal)
                hoursTextField.text = lastSavedRecordForProject.hours
                commentsTextField.text = lastSavedRecordForProject.comment
            }
        }
        
        if saveOnlyFormForAddingNewRecord || editingForm{
            setupSaveButton()
        }
        else {
            disableAllInputFieldsAndControls()
            setupEditButton()
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapToDismissKeyboard:")
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func disableAllInputFieldsAndControls() {
        dateTextField.enabled = false
        statusButton.enabled = false
        typeButton.enabled = false
        hoursTextField.enabled = false
        commentsTextField.enabled = false
        saveRecordButton.enabled = false
    }
    
    private func setupEditButton()
    {
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "enableEditing")
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupSaveButton()
    {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveRecord")
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // MARK: IB Actions
    
    
    @IBAction func statusButtonPressed(sender: UIButton) {
        if record.status == "0" {
            record.status = "1"
        }
        else if record.status == "1" {
            record.status = "0"
        }
        
        statusButton.setTitle(record.valueForType(RecordKey.Status, rawValue: false), forState: .Normal)
    }
    
    @IBAction func typeButtonPressed(sender: UIButton) {
        if record.type == "0" {
            record.type = "1"
        }
        else if record.type == "1" {
            record.type = "0"
        }
        
        typeButton.setTitle(record.valueForType(RecordKey.WorkType, rawValue: false), forState: .Normal)
    }
    
    
    @IBAction func saveRecordButtonPressed(sender: UIButton) {
        saveRecord()
    }
    
    // MARK: UITextField Delegate methods 
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == dateTextField) {
            let calendarPicker = THDatePickerViewController()
            calendarPicker.date = NSDate()
            calendarPicker.delegate = self
            calendarPicker.setAllowClearDate(false)
            calendarPicker.setClearAsToday(true)
            calendarPicker.setAutoCloseOnSelectDate(false)
            calendarPicker.setAllowSelectionOfSelectedDate(true)
            calendarPicker.setDisableHistorySelection(true)
            calendarPicker.setDisableFutureSelection(false)
            calendarPicker.selectedBackgroundColor = UIColor(red: 125/255.0, green: 208/255.0, blue: 0/255.0, alpha: 1.0)
            calendarPicker.currentDateColor = UIColor(red: 242/255.0, green: 121/255.0, blue: 53/255.0, alpha: 1.0)
            calendarPicker.currentDateColorSelected = UIColor.yellowColor()
            presentSemiViewController(calendarPicker, withOptions:
                [KNSemiModalOptionKeys.pushParentBack    : NSNumber(bool: false),
                KNSemiModalOptionKeys.animationDuration : NSNumber(float: 0.1),
                KNSemiModalOptionKeys.shadowOpacity     : NSNumber(float: 0.3)]
            )
            activeTextField = dateTextField
        }
        else if (textField == hoursTextField) {
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
                
                //picker for hours needs to default to a certain value instead of all the way down in 0.5
                if saveOnlyFormForAddingNewRecord {
                    //this is for all other cases (making a new form). This should now use last saved record
                    var lastSavedRecord = LastSavedManager.sharedManager.getRecordForClient(self.record.client, projectString: self.record.project)
                    if let lastSaved = lastSavedRecord {
                        pickerView.selectRow(find(kRecordHoursNames, lastSaved.hours)!, inComponent:0, animated: false)
                    }
                    else {
                        //If there was no last saved record, default to 8.0
                        pickerView.selectRow(find(kRecordHoursNames, "8.0")!, inComponent:0, animated: false)
                    }
                }
                else {
                    //we are editing
                    var indexOfCurrentRecord = find(kRecordHoursNames, record.hours)
                    if let index = indexOfCurrentRecord as Int! {
                        //this is when we are editing form. Picker should start with the already inputted hour
                        pickerView.selectRow(index, inComponent: 0, animated: false)
                    }
                }
                
                return pickerView
            default:
                return nil
        }
    }
    
    
    // MARK: THDatePickerViewController Delegate Methods
    
    
    func datePickerDonePressed(datePicker: THDatePickerViewController!) {
        println("done pressed delegate method")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = dateFormatter.stringFromDate(datePicker.date)
        dismissSemiModalView()
    }
    
    func datePickerCancelPressed(datePicker: THDatePickerViewController!) {
        println("date picker cancel")
        dismissSemiModalView()
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
        dateTextField.enabled = true
        statusButton.enabled = true
        typeButton.enabled = true
        hoursTextField.enabled = true
        commentsTextField.enabled = true
        commentsTextField.placeholder = "Comment (optional)"
        saveRecordButton.enabled = true
        setupSaveButton()
    }
    
    @objc
    private func disableEditing()
    {
        editingForm = false
        commentsTextField.placeholder = nil
        disableAllInputFieldsAndControls()
        setupEditButton()
    }
    
    @objc
    private func saveRecord()
    {
        disableEditing()
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Saving Record"
        
        tempRecord.date = dateTextField.text
        tempRecord.status = record.status
        tempRecord.type = record.type
        tempRecord.hours = hoursTextField.text
        tempRecord.comment = commentsTextField.text
        
        //Last Saved Record must save this
        LastSavedManager.sharedManager.saveRecordForLastSavedRecords(tempRecord)
        
        FirebaseManager.sharedManager.saveRecord(tempRecord, completion: { error in
            if error == nil {
                FirebaseManager.sharedManager.getAllDataOfType(.Projects, completion: {
                    //the reason I get all projects again is because all pinned projects essentially get calculated from there
                    //and then getAllDataofType(.User) will use that data to make the clientsByPinnedProject property in Firebase Singleton
                    //this will help essentially refresh the Pinned Projects list and make sure no funky bugs occur
                    FirebaseManager.sharedManager.getAllDataOfType(.User, completion: {
                        MBProgressHUD.showCompletionHUD(onView: self.view, duration: 1.5, customDoneText: "Completed!", completion: {
                            if let containerVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? ContainerViewController
                            {
                                containerVC.centerNavigationController.dismissViewControllerAnimated(true, completion: nil);
                            }
                        })
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
                
                if let navBarHeight = navigationController?.navigationBar.frame.size.height {
                    var aRect = self.view.frame
                    aRect.size.height = self.view.frame.size.height - keyboardRect.height - navBarHeight - 50
                    
                    if !CGRectContainsPoint(aRect, saveRecordButton.frame.origin) {
                        var scrollPoint = CGPointMake(0.0, saveRecordButton.frame.origin.y-keyboardRect.height-navBarHeight - 50)
                        self.scrollView.setContentOffset(scrollPoint, animated: true)
                    }
                }
            }
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification)
    {
//        if let navBarHeight = navigationController?.navigationBar.frame.size.height {
//            self.scrollView.contentInset = UIEdgeInsets(top: navBarHeight+22, left: 0.0, bottom: 0.0, right: 0.0)
//            self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: navBarHeight+22, left: 0.0, bottom: 0.0, right: 0.0)
//        }
//        else {
//            self.scrollView.contentInset = UIEdgeInsetsZero
//            self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
//        }
        self.scrollView.setContentOffset(CGPointMake(0, -self.scrollView.contentInset.top), animated: true)
    }
    
    
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
