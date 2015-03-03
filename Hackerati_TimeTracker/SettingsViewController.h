//
//  SettingsViewController.h
//  trackerati-ios
//
//  Created by Terry Bu on 2/27/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *notificationsSwitchCell;
@property (weak, nonatomic) IBOutlet UILabel *notifLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notifSwitch;

@property (strong, nonatomic) IBOutlet UITableViewCell *reminderTimeCell;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *reminderTimePicker;

@property (weak, nonatomic) IBOutlet UILabel *reminderExactTimeLabel;



@property (strong, nonatomic) IBOutlet UITableViewCell *clearDataCell;

- (IBAction)clearDataButton:(id)sender;

@end
