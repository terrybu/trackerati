//
//  SettingsViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : MainViewController, UITableViewDataSource
{
    private weak var settingsTableView: UITableView!
    private weak var datePicker: UIDatePicker!
    
    private var settings = [String:Array<String>]()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.blueColor()
        
        let settingsTableView = UITableView(frame: view.frame, style: .Grouped)
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings.keys.array[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
