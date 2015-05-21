//
//  SwitchDatePickerCell.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

protocol SwitchDatePickerCellDelegate: class {
    func switchValueDidChange(cell: SwitchDatePickerCell, on: Bool)
    func dateValueDidChange(cell: SwitchDatePickerCell, date: NSDate)
}

class SwitchDatePickerCell : UITableViewCell
{
    weak var delegate: SwitchDatePickerCellDelegate?
    private(set) weak var titleLabel: UILabel!
    private(set) weak var onOffSwitch: UISwitch!
    private(set) weak var datePickerView: UIDatePicker!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        clipsToBounds = true
        setupLabelAndSwitch()
        setupDatePickerView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabelAndSwitch()
    {
        let cellWidth = contentView.frame.size.width
        let cellHeight = contentView.frame.size.height
        let leftMargin = layoutMargins.left
        let titleLabelRect = CGRect(x: leftMargin, y: 0.0, width: contentView.frame.size.width, height: contentView.frame.size.height)
        
        let titleLabel = UILabel(frame: titleLabelRect)
        titleLabel.text = "Notifications"
        contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        let onOffSwitch = UISwitch(frame: CGRectZero)
        onOffSwitch.addTarget(self, action: "switchValueChanged:", forControlEvents: .ValueChanged)
        onOffSwitch.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(onOffSwitch)
        let constraints = [
            NSLayoutConstraint(item: onOffSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: self.titleLabel, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: onOffSwitch, attribute: .RightMargin, relatedBy: .Equal, toItem: self.contentView, attribute: .RightMargin, multiplier: 0.98, constant: 0.0)
        ]
        contentView.addConstraints(constraints)
        self.onOffSwitch = onOffSwitch
    }
    
    private func setupDatePickerView()
    {
        var datePickerFrame = CGRectZero
        datePickerFrame.origin = CGPoint(x: 0.0, y: titleLabel.frame.size.height)
        let datePickerView = UIDatePicker(frame: datePickerFrame)
        datePickerView.datePickerMode = .Time
        datePickerView.addTarget(self, action: "dateValueChanged:", forControlEvents: .ValueChanged)
        contentView.addSubview(datePickerView)
        self.datePickerView = datePickerView
    }
    
    private func showTimePicker(show: Bool, animated: Bool) {
        
        let animationDuration: NSTimeInterval = animated ? 0.2 : 0.0
        let animationHeight = datePickerView.intrinsicContentSize().height
        
        UIView.animateWithDuration(animationDuration) {
            self.frame.size.height += show ? animationHeight : -animationHeight
        }
    }
    
    // MARK: UISwitch Selector
    
    @objc
    private func switchValueChanged(onOffSwitch: UISwitch)
    {
        showTimePicker(onOffSwitch.on, animated: true)
        delegate?.switchValueDidChange(self, on: onOffSwitch.on)
        
        if onOffSwitch.on {
            delegate?.dateValueDidChange(self, date: datePickerView.date) // save date as well when turning on
        }
    }
    
    // MARK: UIDatePicker Selector
    
    @objc
    private func dateValueChanged(datePicker: UIDatePicker)
    {
        delegate?.dateValueDidChange(self, date: datePicker.date)
    }
    
}
