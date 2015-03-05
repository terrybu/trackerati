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
#import "LoginManager.h"

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
//    NSArray *eventArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    NSLog(eventArray.description);
    
    self.notifSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kRemindersOn];
    if (self.notifSwitch.on) {
        NSInteger hour = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderHourSaved];
        NSInteger mins = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderMinutesSaved];
        if (hour == 0 && mins == 8){
            //set default placeholder text at 6PM because at initial launch, that's our default notification time
            self.reminderExactTimeLabel.text = @"Currently Set: 06:00 PM";
        }
        else {
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
            return @"Daily Reminders (M-F)";
            break;
//        case 1:
//            return @"Clear Data";
//            break;
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
//    else if (section == 1)
//        return 1;
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1)
        return 180;
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = self.notificationsSwitchCell;
            self.notifLabel.text = @"Turn Reminders On/Off";
        }
        else if (indexPath.row == 1) {
            cell = self.reminderTimeCell;
            self.reminderLabel.text = @"Reminder Time";
        }
    }
//    else if (indexPath.section == 1) {
//        if (indexPath.row == 0)
//            cell = self.clearDataCell;
//    }
    else if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}





- (IBAction)clearDataButton:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Confirmation" message:@"This will delete all default settings and on-device trackerati data. You will need internet access and login again from Home screen to regain all data from Firebase server. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Confirm"])
        [self deleteAllCache];
}

- (void) deleteAllCache {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    [self.tableView reloadData];
}


@end
