//
//  SwitchDatePickerCell.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

protocol SwitchDatePickerCellDelegate: class {
    func switchValueDidChange(cell: SwitchDatePickerCell, on: Bool)
}

class SwitchDatePickerCell : UITableViewCell
{
    weak var delegate: SwitchDatePickerCellDelegate?
    weak var titleLabel: UILabel!
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
        let titleLabel = UILabel(frame: contentView.frame)
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
    
    func setupDatePickerView()
    {
        var datePickerFrame = CGRectZero
        datePickerFrame.origin = CGPoint(x: 0.0, y: titleLabel.frame.size.height)
        let datePickerView = UIDatePicker(frame: datePickerFrame)
        datePickerView.sizeToFit()
        datePickerView.datePickerMode = .Time
        contentView.addSubview(datePickerView)
        self.datePickerView = datePickerView
    }
    
    func showTimePicker(show: Bool, animated: Bool)
    {
        let animationDuration: NSTimeInterval
        let animatedHeight: CGFloat
        if show {
            animatedHeight = datePickerView.intrinsicContentSize().height
        }
        else {
            animatedHeight = -datePickerView.intrinsicContentSize().height
        }
        
        if animated {
            animationDuration = 0.2
        }
        else {
            animationDuration = 0.0
        }
        
        let accessoryFrame = onOffSwitch.frame
        let currentFrame = self.frame
        UIView.animateWithDuration(animationDuration, animations: {
            self.onOffSwitch.frame = accessoryFrame
            self.frame = CGRect(x: currentFrame.origin.x, y: currentFrame.origin.y, width: self.frame.size.width, height: self.frame.size.height + animatedHeight)
        })
    }
    
    func switchValueChanged(onOffSwitch: UISwitch)
    {
        showTimePicker(onOffSwitch.on, animated: true)
        delegate?.switchValueDidChange(self, on: onOffSwitch.on)
    }
    
}
