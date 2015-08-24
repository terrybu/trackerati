//
//  NSDateExtension.swift
//  Trackerati
//
//  Created by Terry Bu on 7/17/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

class CustomDateFormatter {
    
    static let sharedInstance = CustomDateFormatter()
    
    let dateFormatter = NSDateFormatter()
    
    init() {
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
    }
    
    func formatDateToOurStringFormat(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    func returnTodaysDateStringInFormat() -> String {
        let today = dateFormatter.stringFromDate(NSDate())
        return today
    }
    
    
}