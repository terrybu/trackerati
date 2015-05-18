//
//  SettingsViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import UIKit

enum SettingType: String {
    case Date = "Date"
}

class SettingsViewController : MainViewController, UITableViewDelegate, UITableViewDataSource, SwitchDatePickerCellDelegate
{
    let defaultTableViewCellHeight: CGFloat = 44.0
    
    private weak var settingsTableView: UITableView!
    private weak var datePicker: UIDatePicker!
    
    private var settings = [String:Array<String>]()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.blueColor()
        
        settings = ["Notifications":[SettingType.Date.rawValue]]
        
        let settingsTableView = UITableView(frame: view.frame, style: .Grouped)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.allowsSelection = false
        view.addSubview(settingsTableView)
        self.settingsTableView = settingsTableView
    }
    
    // MARK: UITableView Delegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let sectionKey = settings.keys.array[indexPath.section]
        let cellType = settings[sectionKey]?[indexPath.row]
        if cellType == SettingType.Date.rawValue && TrackeratiUserDefaults.standardDefaults.notificationsOn() {
            return defaultTableViewCellHeight * 6.0
        }
        return defaultTableViewCellHeight
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
        var cell = SwitchDatePickerCell(style: .Default, reuseIdentifier: "cell")
        cell.onOffSwitch.setOn(TrackeratiUserDefaults.standardDefaults.notificationsOn(), animated: false)
        if cell.onOffSwitch.on {
            if let savedTime = TrackeratiUserDefaults.standardDefaults.notificationTime() {
                cell.datePickerView.setDate(savedTime, animated: false)
            }
        }
        cell.delegate = self
        return cell
    }

    // MARK: SwitchDatePickerCell Delegate
    
    func switchValueDidChange(cell: SwitchDatePickerCell, on: Bool) {
        TrackeratiUserDefaults.standardDefaults.setNotificationsOn(on)
        
        if on && UIApplication.sharedApplication().currentUserNotificationSettings() != .None {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge , categories: nil))
        }
    }
    
    func dateValueDidChange(cell: SwitchDatePickerCell, date: NSDate) {
        TrackeratiUserDefaults.standardDefaults.setNotificationDate(date)
    }
    
}
