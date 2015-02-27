//
//  SettingsViewController.m
//  trackerati-ios
//
//  Created by Terry Bu on 2/27/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "SettingsViewController.h"
#import "HConstants.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Settings";
    
    UIImage *drawerButtonImage = [UIImage imageNamed:kIconDrawer];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(actionToggleLeftDrawer)];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSettings)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void) saveSettings {
    bool notificationSwitchIsOn = self.notifSwitch.on;
    NSDate *notificationTimeChosen = self.reminderTimePicker.date;
    NSLog(@"%d %@", notificationSwitchIsOn, notificationTimeChosen.description);
}


- (void)actionToggleLeftDrawer {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Daily Notifications";
            break;
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1)
        return 180;
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = self.notificationsSwitchCell;
        self.notifLabel.text = @"Daily Reminders On";
    }
    else if (indexPath.row == 1) {
        cell = self.reminderTimeCell;
        self.reminderLabel.text = @"Daily Reminder Time";
    }
    else if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        datePicker.datePickerMode = UIDatePickerModeTime;
        [datePicker setCenter:CGPointMake(150, 500)]; // place the pickerView outside the screen boundaries
        [UIView beginAnimations:@"slideIn" context:nil];
        [datePicker setCenter:CGPointMake(150, 250)];
        [UIView commitAnimations];
    }
}





@end
