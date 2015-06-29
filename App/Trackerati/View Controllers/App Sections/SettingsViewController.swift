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
        
        settings = [
            ("Notifications", SettingType.Notifications),
            ("Status", SettingType.Status)
        ]
        
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
            var switchDatePickercell = SwitchDatePickerCell(style: .Default, reuseIdentifier: "switchDatePickerCell")
            
            //set up cell UI considering what was saved in Defaults
            switchDatePickercell.onOffSwitch.setOn(TrackeratiUserDefaults.standardDefaults.notificationsOn(), animated: false)
            if switchDatePickercell.onOffSwitch.on {
                if let savedTime = TrackeratiUserDefaults.standardDefaults.notificationTime() {
                    switchDatePickercell.datePickerView.setDate(savedTime, animated: false)
                }
            }
            switchDatePickercell.delegate = self
            return switchDatePickercell
        }
        
        let employmentStatusCell = tableView.dequeueReusableCellWithIdentifier("employmentStatusCell", forIndexPath: indexPath) as! EmploymentStatusCellTableViewCell
        //set up cell UI considering what was saved in Defaults
        let savedDefaultEmploymentStatus = TrackeratiUserDefaults.standardDefaults.getEmploymentStatus()
        if savedDefaultEmploymentStatus == EmploymentStatusEnum.FullTime {
            employmentStatusCell.segmentedControl.selectedSegmentIndex = 0
        }
        else if savedDefaultEmploymentStatus == EmploymentStatusEnum.PartTime {
            employmentStatusCell.segmentedControl.selectedSegmentIndex = 1
        }

        employmentStatusCell.delegate = self
        return employmentStatusCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = settings[indexPath.section].1
        if cellType == SettingType.Notifications && TrackeratiUserDefaults.standardDefaults.notificationsOn() {
            return defaultTableViewCellHeight * 6.0
        }

        return defaultTableViewCellHeight
    }
  
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && TrackeratiUserDefaults.standardDefaults.notificationsOn() {
            return 44
        }
        else if section == 1 {
            return 44
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            var label = UILabel(frame: CGRectMake(50, 0, 50, 200))
            label.text = "*This allows all your future record forms to default to above"
            label.textColor = UIColor.grayColor()
            label.numberOfLines = 0
            label.font =  UIFont.systemFontOfSize(13)
            label.textAlignment = NSTextAlignment.Center
            
            return label
        }
        return nil
    }
    
    // MARK: SwitchDatePickerCell Delegate
    func switchValueDidChange(cell: SwitchDatePickerCell, on: Bool) {
        
        TrackeratiUserDefaults.standardDefaults.setNotificationsOn(on)
        self.settingsTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        
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
                TrackeratiUserDefaults.standardDefaults.setEmploymentStatus(EmploymentStatusEnum.FullTime)
            case 1:
                TrackeratiUserDefaults.standardDefaults.setEmploymentStatus(EmploymentStatusEnum.PartTime)
            default:
                break
        }
    }
    
}
