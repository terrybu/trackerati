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
#import "DailyNotificationManager.h"

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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.notifSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kRemindersOn];
    if (self.notifSwitch.on) {
        NSInteger hour = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderHourSaved];
        NSInteger mins = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderMinutesSaved];
        if (hour && mins) {
            NSLog(@"%ld %ld", hour, mins);
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc]init];
            [components setHour:hour];
            [components setMinute:mins];
            self.reminderTimePicker.date = [calendar dateFromComponents:components];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];
            NSString *date = [formatter stringFromDate:self.reminderTimePicker.date];
            self.reminderExactTimeLabel.text = [NSString stringWithFormat:@"Currently Set: %@", date];
        }
        else {
            self.reminderExactTimeLabel.text = @"Currently Set: 06:00 PM";
        }
    }
    else {
        self.reminderExactTimeLabel.text = [NSString stringWithFormat:@"Currently Disabled"];
    }
}

- (void) saveSettings {
    bool notificationSwitchIsOn = self.notifSwitch.on;
    NSDate *notificationTimeChosen = self.reminderTimePicker.date;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:notificationTimeChosen];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    
    [[NSUserDefaults standardUserDefaults]setBool:notificationSwitchIsOn forKey:kRemindersOn];
    if (notificationSwitchIsOn) {
        [[NSUserDefaults standardUserDefaults]setInteger:hour forKey:kReminderHourSaved];
        [[NSUserDefaults standardUserDefaults]setInteger:minutes forKey:kReminderMinutesSaved];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];
        NSString *date = [formatter stringFromDate:self.reminderTimePicker.date];
        self.reminderExactTimeLabel.text = [NSString stringWithFormat:@"Currently Set: %@", date];
    }
    else {
        self.reminderExactTimeLabel.text = [NSString stringWithFormat:@"Currently Disabled"];
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Saved" message:@"Your daily reminder settings have been saved" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    
    [[DailyNotificationManager sharedManager] refreshNotificationsSettings];
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}





@end
