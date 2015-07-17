//
//  NSDateExtension.swift
//  Trackerati
//
//  Created by Terry Bu on 7/17/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

class CustomDateFormatter {
    
    class func formatDateToOurStringFormat(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.stringFromDate(date)
    }
    
    class func returnTodaysDateStringInFormat() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let today = dateFormatter.stringFromDate(NSDate())
        return today
    }
    
    
}