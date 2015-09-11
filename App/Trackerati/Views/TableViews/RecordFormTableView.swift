//
//  RecordFormTableView.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/26/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class RecordFormTableView : UITableView
{
    convenience init(frame: CGRect) {
        self.init(frame: frame, style: .Plain)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
