//
//  RecordFormViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import UIKit

class RecordFormViewController : UIViewController
{
    private let record: Record
    
    init(record: Record)
    {
        self.record = record
        super.init(nibName: nil, bundle: nil)
        title = record.date
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.blueColor()
    }
    
}
