//
//  SettingsViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

enum SettingType {
    case Status, Notifications
}

class SettingsViewController : MainViewController, UITableViewDelegate, UITableViewDataSource, SwitchDatePickerCellDelegate, EmploymentStatusCellDelegate
{
    let defaultTableViewCellHeight: CGFloat = 44.0
    
    private weak var settingsTableView: UITableView!
    private weak var datePicker: UIDatePicker!
    
    private var settings: [(String, SettingType)]!
    
    override func loadView() {
        super.loadView()
        setNavUIToHackeratiColors()
        
        settings = [("Status", SettingType.Status), ("Notifications", SettingType.Notifications)]
        
        let settingsTableView = UITableView(frame: view.frame, style: .Grouped)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.allowsSelection = false
        view.addSubview(settingsTableView)
        self.settingsTableView = settingsTableView
        
        self.settingsTableView.registerNib(UINib(nibName: "EmploymentStatusCellTableViewCell", bundle: nil), forCellReuseIdentifier: "employmentStatusCell")
    }
    
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (settings[section].0 == "Status") {
            return "Employment Status"
        }
        return settings[section].0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if settings[indexPath.section].1 == SettingType.Notifications {
            var cell = SwitchDatePickerCell(style: .Default, reuseIdentifier: "switchDatePickerCell")
            cell.onOffSwitch.setOn(TrackeratiUserDefaults.standardDefaults.notificationsOn(), animated: false)
            if cell.onOffSwitch.on {
                if let savedTime = TrackeratiUserDefaults.standardDefaults.notificationTime() {
                    cell.datePickerView.setDate(savedTime, animated: false)
                }
            }
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("employmentStatusCell", forIndexPath: indexPath) as! EmploymentStatusCellTableViewCell
        cell.delegate = self
//        var statusButton = UIButton(frame: CGRect(x: 45, y: 0, width: 250, height: 25))
//        statusButton.setTitle("Full-Time Employee", forState: UIControlState.Normal)
//        statusButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
//        statusButton.addTarget(self, action: "pressedStatusButton", forControlEvents: .TouchUpInside)
//        cell.addSubview(statusButton)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = settings[indexPath.row].1
        if cellType == SettingType.Notifications && TrackeratiUserDefaults.standardDefaults.notificationsOn() {
            return defaultTableViewCellHeight * 6.0
        }
        return defaultTableViewCellHeight
    }
    
    // Private
    @objc
    private func pressedStatusButton() {
        println("pressed button")
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
    
    // EmploymentStatusCell Delegate
    
    func segmentControlValueChanged(cell: EmploymentStatusCellTableViewCell) {
        switch cell.segmentedControl.selectedSegmentIndex {
        case 0:
            println("fulltime")
        case 1:
            println("part-time")
        default:
            break
        }
    }
    
}
