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
        
        settings = ["Notifications":["Date"]]
        
        let settingsTableView = UITableView(frame: view.frame, style: .Grouped)
        settingsTableView.dataSource = self
        settingsTableView.allowsSelection = false
        view.addSubview(settingsTableView)
        self.settingsTableView = settingsTableView
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings.keys.array[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Make it the number of items for that setting
        let currentGroup = settings.keys.array[section]
        if let groupCells = settings[currentGroup] {
            return groupCells.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = SwitchDatePickerCell(style: .Default, reuseIdentifier: "cell")
        return cell
    }
}
