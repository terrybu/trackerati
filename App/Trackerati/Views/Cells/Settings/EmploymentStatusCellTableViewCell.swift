//
//  EmploymentStatusCellTableViewCell.swift
//  Trackerati
//
//  Created by Terry Bu on 6/29/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit


protocol EmploymentStatusCellDelegate: class {
    func segmentControlValueChanged(cell: EmploymentStatusCellTableViewCell)
}


class EmploymentStatusCellTableViewCell: UITableViewCell {

    weak var delegate : EmploymentStatusCellDelegate?
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    
    //with this init with NSCoder, custom tableviewcell doesn't work, doesn't load NIB correctly
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UISegmentedControl.appearance().setTitleTextAttributes(NSDictionary(objects: [UIFont.systemFontOfSize(16.0)], forKeys: [NSFontAttributeName]) as [NSObject : AnyObject], forState: UIControlState.Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        self.delegate?.segmentControlValueChanged(self)
    }
    
}
