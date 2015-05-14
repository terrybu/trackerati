//
//  SwitchDatePickerCell.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

protocol SwitchDatePickerCellDelegate: class {
    func switchValueDidChange(value: Bool)
}

class SwitchDatePickerCell : UITableViewCell
{
    private weak var delegate: SwitchDatePickerCellDelegate?
    private weak var onOffSwitch: UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        setupLabelAndSwitch()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabelAndSwitch()
    {
        let cellWidth = contentView.frame.size.width
        let cellHeight = contentView.frame.size.height
        let titleLabel = UILabel(frame: contentView.frame)
        titleLabel.text = "Notifications"
        contentView.addSubview(titleLabel)
        
        let onOffSwitch = UISwitch(frame: CGRectZero)
        onOffSwitch.addTarget(self, action: "switchValueChanged:", forControlEvents: .ValueChanged)
        accessoryView = onOffSwitch
        self.onOffSwitch = onOffSwitch
    }
    
    func setupDatePickerView()
    {
        let cellWidth = contentView.frame.size.width
        let datePicker = UIDatePicker(frame: contentView.frame)
    }
    
    func switchValueChanged(onOffSwitch: UISwitch)
    {
        delegate?.switchValueDidChange(onOffSwitch.on)
    }
    
}
