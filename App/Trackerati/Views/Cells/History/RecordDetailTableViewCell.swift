//
//  RecordDetailTableViewCell.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/26/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

let kDefaultNilInformationValue = "Information Unavailable"

protocol RecordDetailTableViewCellDelegate : class {
    func textFieldTextDidChangeForCell(cell: RecordDetailTableViewCell, newText: String)
}

class RecordDetailTableViewCell : UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    private weak var infoTextField: UITextField!
    private weak var delegate: RecordDetailTableViewCellDelegate?
    
    private var initialTextValue: String!
    
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
            
            initialTextValue = infoTextField.text
        }
    }
    
    var editable: Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextField()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignFirstResponder() -> Bool {
        infoTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    private func setupTextField()
    {
        let infoTextField = UITextField(frame: CGRectZero)
        infoTextField.delegate = self
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
    
    private func createPickerViewForType(cellType: RecordKey) -> UIPickerView?
    {
        switch cellType
        {
        case .Status, .WorkType:
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
            
        case .Hours:
            infoTextField.keyboardType = .NumberPad
            
        case .Status, .WorkType:
            infoTextField.tintColor = UIColor.clearColor() // hides blinking cursor
            infoTextField.inputView = createPickerViewForType(type)
            
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
        return infoType! == .Status ? kRecordStatusNames.count : kRecordWorkTypeNames.count
    }
    
    // MARK: UIPickerView Delegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let options = infoType! == .Status ? kRecordStatusNames : kRecordWorkTypeNames
        information = options[row]
        delegate?.textFieldTextDidChangeForCell(self, newText: String(row + 1))
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let options = infoType! == .Status ? kRecordStatusNames : kRecordWorkTypeNames
        return options[row]
    }
    
    // MARK: UITextField Delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        switch infoType!
        {
        case .Client, .Project:
            return false
            
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if initialTextValue != textField.text {
            delegate?.textFieldTextDidChangeForCell(self, newText: textField.text)
        }
    }
    
}
