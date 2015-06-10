//
//  RecordDetailTableViewCell.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/26/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

let kDefaultNilInformationValue = ""

protocol RecordDetailTableViewCellDelegate : class {
    func didSelectTextFieldOnCell(cell: RecordDetailTableViewCell?)
    func textFieldTextDidChangeForCell(cell: RecordDetailTableViewCell, newText: String)
}

class RecordDetailTableViewCell : UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    private weak var infoTextField: UITextField!
    weak var delegate: RecordDetailTableViewCellDelegate?
    
    var infoType: RecordKey! {
        didSet {
            setupCellForType(infoType)
        }
    }
    
    var information: String? {
        didSet {
            if let info = information {
                infoTextField.text = info
            }
            else {
                infoTextField.text = kDefaultNilInformationValue
            }
        }
    }
    
    var editingInfo = false {
        didSet {
            if editingInfo && infoType! != .Client && infoType! != .Project {
                infoTextField?.textColor = UIColor.blackColor()
            }
            else {
                infoTextField?.textColor = UIColor.grayColor()
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextField()
    }
    
    override func isFirstResponder() -> Bool {
        return infoTextField.isFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        infoTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField()
    {
        let infoTextField = UITextField(frame: CGRectZero)
        infoTextField.returnKeyType = .Done
        infoTextField.delegate = self
        
        if !editingInfo {
            infoTextField.textColor = UIColor.grayColor()
        }
        else {
            infoTextField.textColor = UIColor.blackColor()
        }
        
        infoTextField.setTranslatesAutoresizingMaskIntoConstraints(false)
        let constraints = [
            NSLayoutConstraint(item: infoTextField, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: infoTextField, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: infoTextField, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: infoTextField, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0)
        ]
        contentView.addSubview(infoTextField)
        contentView.addConstraints(constraints)
        self.infoTextField = infoTextField
    }
    
    // MARK: Private
    
    private func datePickerViewForEditing() -> UIDatePicker
    {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.datePickerMode = .Date
        let dateFormatter = NSDateFormatter()
        
        if let info = information {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            if let date = dateFormatter.dateFromString(info) {
                datePicker.date = date
            }
            else {
                datePicker.date = NSDate()
            }
        }
        else {
            datePicker.date = NSDate()
        }
        
        datePicker.addTarget(self, action: "datePickerChanged:", forControlEvents: .ValueChanged)
        return datePicker
    }
    
    private func pickerViewForType(cellType: RecordKey) -> UIView?
    {
        switch cellType
        {
        case .Hours, .Status, .WorkType:
            let pickerView = UIPickerView()
            pickerView.backgroundColor = UIColor.whiteColor()
            pickerView.delegate = self
            pickerView.dataSource = self
            return pickerView
            
        default:
            return nil
        }
    }
    
    private func setupCellForType(type: RecordKey)
    {
        switch type
        {
        case .Client, .Project:
            infoTextField.textColor = UIColor.grayColor()
            
        case .Date:
            infoTextField.tintColor = UIColor.clearColor() // hides blinking cursor
            infoTextField.inputView = datePickerViewForEditing()
            
        case .Hours, .Status, .WorkType:
            infoTextField.tintColor = UIColor.clearColor() // hides blinking cursor
            infoTextField.inputView = pickerViewForType(type)
            
        case .Comment:
            break
            
        default:
            break
        }
    }
    
    // MARK: UIDatePicker Selectors
    
    @objc
    private func datePickerChanged(datePicker: UIDatePicker)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        information = dateFormatter.stringFromDate(datePicker.date)
    }
    
    // MARK: UIPickerView Datasource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch infoType! {
        case .Hours:
            return kRecordHoursNames.count
            
        case .Status:
            return kRecordStatusNames.count
            
        case .WorkType:
            return kRecordWorkTypeNames.count
            
        default:
            return 0
        }
    }
    
    // MARK: UIPickerView Delegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let options: [String]
        let newValue: String
        switch infoType! {
        case .Hours:
            options = kRecordHoursNames
            newValue = String(format: "%.1f", (Double(row) + 1.0) / 2.0)
            
        case .Status:
            options = kRecordStatusNames
            newValue = String(row)
        
        case .WorkType:
            options = kRecordWorkTypeNames
            newValue = String(row)
            
        default:
            options = []
            newValue = ""
        }
        
        delegate?.textFieldTextDidChangeForCell(self, newText: String(newValue))
        information = options[row]
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let options: [String]
        switch infoType! {
        case .Hours:
            options = kRecordHoursNames
            
        case .Status:
            options = kRecordStatusNames
            
        case .WorkType:
            options = kRecordWorkTypeNames
            
        default:
            options = []
        }
        return options[row]
    }
    
    // MARK: UITextField Delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        switch infoType!
        {
        case .Client, .Project:
            delegate?.didSelectTextFieldOnCell(nil)
            return false
            
        default:
            delegate?.didSelectTextFieldOnCell(self)
            return editingInfo
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return resignFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        delegate?.textFieldTextDidChangeForCell(self, newText: textField.text)
    }
}
