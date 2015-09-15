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
    @IBOutlet weak var dateButton: UIButton!
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
    private var activeTextField: UITextField?
    private var datePicker: UIDatePicker?
    private var saveOnlyFormForAddingNewRecord = false

    init(record: Record)
    {
        self.record = record
        tempRecord = record
        super.init(nibName: "RecordFormViewController", bundle: nil)
        title = record.date
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    convenience init(record: Record, saveOnlyFormForAddingNewRecord: Bool)
    {
        self.init(record: record)
        self.saveOnlyFormForAddingNewRecord = saveOnlyFormForAddingNewRecord
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setNavUIToHackeratiColors()
        
        clientLabel.text = self.record.client
        projectLabel.text = self.record.project
        
        if !self.record.date.isEmpty {
            dateButton.setTitle(self.record.date, forState: UIControlState.Normal)
        } else {
            //if its empty, we put today's date on there in a string
        dateButton.setTitle(CustomDateFormatter.sharedInstance.returnTodaysDateStringInFormat(), forState: UIControlState.Normal)
        }
        
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
            let lastSavedData = LastSavedManager.sharedManager.getRecordForClient(self.record.client, projectString: self.record.project)
            if let lastSavedRecordForProject = lastSavedData {
                record.type = lastSavedRecordForProject.type
                typeButton.setTitle(record.valueForType(worktypeRecordType, rawValue: false), forState: .Normal)
                hoursTextField.text = lastSavedRecordForProject.hours
                commentsTextField.text = lastSavedRecordForProject.comment
            }
        }
        
        setupSaveButton()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapToDismissKeyboard:")
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    // MARK: Private
    
   private func pickerViewForType(cellType: RecordKey) -> UIView?
    {
        switch cellType {
        case .Hours:
            let pickerView = UIPickerView()
            pickerView.backgroundColor = UIColor.whiteColor()
            pickerView.delegate = self
            pickerView.dataSource = self
            infoType = cellType
            
            //picker for hours needs to default to a certain value instead of all the way down in 0.5
            if saveOnlyFormForAddingNewRecord {
                //this is for all other cases (making a new form). This should now use last saved record
                let lastSavedRecord = LastSavedManager.sharedManager.getRecordForClient(self.record.client, projectString: self.record.project)
                if let lastSaved = lastSavedRecord {
                    pickerView.selectRow(kRecordHoursNames.indexOf(lastSaved.hours)!, inComponent:0, animated: false)
                } else {
                    //If there was no last saved record, default to 8.0
                    pickerView.selectRow(kRecordHoursNames.indexOf("8.0")!, inComponent:0, animated: false)
                }
            } else {
                //we are editing
                let indexOfCurrentRecord = kRecordHoursNames.indexOf(record.hours)
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
    
    
    private func disableAllInputFieldsAndControls() {
        dateButton.enabled = false
        statusButton.enabled = false
        typeButton.enabled = false
        hoursTextField.enabled = false
        commentsTextField.enabled = false
        saveRecordButton.enabled = false
    }
    
    
    private func setupSaveButton()
    {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveRecord")
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // MARK: IB Actions
    
    @IBAction func dateButtonPressed(sender: UIButton) {
        let calendarPicker = THDatePickerViewController()
        
        calendarPicker.date = CustomDateFormatter.sharedInstance.dateFormatter.dateFromString(dateButton.titleLabel!.text!)
        calendarPicker.delegate = self
        calendarPicker.setAllowClearDate(false)
        calendarPicker.setClearAsToday(true)
        calendarPicker.setAutoCloseOnSelectDate(false)
        calendarPicker.setAllowSelectionOfSelectedDate(true)
        calendarPicker.setDisableHistorySelection(false)
        calendarPicker.setDisableFutureSelection(false)
        calendarPicker.selectedBackgroundColor = UIColor(red: 125/255.0, green: 208/255.0, blue: 0/255.0, alpha: 1.0)
        calendarPicker.currentDateColor = UIColor(red: 242/255.0, green: 121/255.0, blue: 53/255.0, alpha: 1.0)
        calendarPicker.currentDateColorSelected = UIColor.yellowColor()
        
        if let userRecordsSortedByDateInTuples = FirebaseManager.sharedManager.userRecordsSortedByDateInTuples {
            let justDates = userRecordsSortedByDateInTuples.map { $0.0}
            print(justDates)
            //        let dateStringsArray = (FirebaseManager.sharedManager.allUserRecords! as NSArray).valueForKeyPath("date") as! [String]
            //        print(dateStringsArray.description)
            
            //this is the little dots logic for calendar picker view
            //set a little dot below every date that has a Record in history associated with it
            //to display "Hey, you already did a record on that date!"
            calendarPicker.setDateHasItemsCallback({ (date: NSDate!) -> Bool in
                if (justDates.indexOf((CustomDateFormatter.sharedInstance.dateFormatter.stringFromDate(date))) != nil) {
                    return true
                }
                return false
            })
        }
        
        let pushParentBack = KNSemiModalOptionKeys.pushParentBack.takeRetainedValue() as String
        let animationDuration = KNSemiModalOptionKeys.animationDuration.takeRetainedValue() as String
        let shadowOpac = KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue() as String
        let dict: Dictionary<String, NSNumber> = [
            pushParentBack:NSNumber(bool: false),
            animationDuration:NSNumber(float: 0.1),
            shadowOpac:NSNumber(float: 0.3)
        ]
        
        presentSemiViewController(calendarPicker, withOptions: dict)
    }
    
    
    @IBAction func statusButtonPressed(sender: UIButton) {
        if record.status == "0" {
            record.status = "1"
        } else if record.status == "1" {
            record.status = "0"
        }
        
        statusButton.setTitle(record.valueForType(RecordKey.Status, rawValue: false), forState: .Normal)
    }
    
    @IBAction func typeButtonPressed(sender: UIButton) {
        if record.type == "0" {
            record.type = "1"
        } else if record.type == "1" {
            record.type = "0"
        }
        
        typeButton.setTitle(record.valueForType(RecordKey.WorkType, rawValue: false), forState: .Normal)
    }
    
    
    @IBAction func saveRecordButtonPressed(sender: UIButton) {
        saveRecord()
    }
    
    // MARK: UITextField Delegate methods 
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == commentsTextField) {
            activeTextField = commentsTextField
        } else if (textField == hoursTextField) {
            activeTextField = hoursTextField
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    // MARK: THDatePickerViewController Delegate Methods
    func datePicker(datePicker: THDatePickerViewController!, selectedDate: NSDate!) {
        dateButton.setTitle(CustomDateFormatter.sharedInstance.formatDateToOurStringFormat(datePicker.date), forState: .Normal)
    }
    
    func datePickerDonePressed(datePicker: THDatePickerViewController!) {
        dismissSemiModalView()
    }
    
    func datePickerCancelPressed(datePicker: THDatePickerViewController!) {
        //if you pressed cancel, then we don't make any changes to dateButton's title and reset
        if (saveOnlyFormForAddingNewRecord) {
            //then we just reset back to today's date
        dateButton.setTitle(CustomDateFormatter.sharedInstance.returnTodaysDateStringInFormat(), forState: UIControlState.Normal)
        } else {
            //this case is editing an old record, we set dateButton to whatever record date was
            dateButton.setTitle(self.record.date, forState: UIControlState.Normal)
        }
        dismissSemiModalView()
    }
    
    
    // MARK: UIPickerView Datasource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kRecordHoursNames.count
    }
    
    // MARK: UIPickerView Delegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let options: [String]
        options = kRecordHoursNames
//        let newValue = String(format: "%.1f", (Double(row) + 1.0) / 2.0)
        
        hoursTextField.text = options[row]
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let options: [String]
        options = kRecordHoursNames
        return options[row]
    }
    
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func saveRecord()
    {
        tempRecord.date = dateButton.titleLabel!.text!
        tempRecord.status = record.status
        tempRecord.type = record.type
        tempRecord.hours = hoursTextField.text!
        tempRecord.comment = commentsTextField.text
        
        if sameProjectAlreadyPostedToday(tempRecord) {
            print("same project was already posted today")
            let alertController = UIAlertController(title: "Same project was already posted today", message:
                "Would you like to submit this project more than once in one day?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Yes, submit again", style: UIAlertActionStyle.Default,handler: { (actionSheetController) -> Void in
                    self.submit()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            submit()
        }
    }
    
    private func submit() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Saving Record"
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

        
    
    private func sameProjectAlreadyPostedToday(tempRecord: Record) -> Bool {
        let possibleRecords = FirebaseManager.sharedManager.getTodaysRecords()
        if let todaysRecords = possibleRecords {
            //iterate through Record objects in today's Records array, check if contain the same client and project name of tempRecord
            for record in todaysRecords {
                if record.client == tempRecord.client && record.project == tempRecord.project {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: UIKeyboard Notification Selectors
    
    @objc
    private func keyboardDidShow(notification: NSNotification)
    {
        if let keyboardDict = notification.userInfo {
            if let keyboardRect = keyboardDict[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue {
                
                if let navBarHeight = navigationController?.navigationBar.frame.size.height {
                    var aRect = self.view.frame
                    aRect.size.height = self.view.frame.size.height - keyboardRect.height - navBarHeight - 50
                    
                    if !CGRectContainsPoint(aRect, saveRecordButton.frame.origin) {
                        let scrollPoint = CGPointMake(0.0, saveRecordButton.frame.origin.y-keyboardRect.height-navBarHeight - 50)
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
        if activeTextField == commentsTextField  {
            commentsTextField.resignFirstResponder()
        } else if activeTextField == hoursTextField  {
            hoursTextField.resignFirstResponder()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
