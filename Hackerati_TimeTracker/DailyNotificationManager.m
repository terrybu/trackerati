//
//  WeeklyNotificationManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "DailyNotificationManager.h"
#import "HConstants.h"

@interface DailyNotificationManager ()

@end

@implementation DailyNotificationManager

+ (DailyNotificationManager*)sharedManager{
    static DailyNotificationManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[DailyNotificationManager alloc]init];
    });
    return shareManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self refreshNotificationsSettings];
    }
    return self;
}





- (void) refreshNotificationsSettings {
    bool remindersOn = [[NSUserDefaults standardUserDefaults]boolForKey:kRemindersOn];
    if (remindersOn) {
        [self scheduleNotificationsWithSavedSettings];
    }
    else if (remindersOn == NO){
        bool ranAppBefore = [[NSUserDefaults standardUserDefaults]boolForKey:kRanAppBeforeCheck];
        if (ranAppBefore) {
            NSLog(@"didn't want reminders - turning it off");
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        else {
            NSLog(@"this is first time we are running the app - turn on daily reminder by default");
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kRemindersOn];
            [self firstTimeRunSettings];
        }
    }
}

- (void) firstTimeRunSettings {
    self.localNotif = [[UILocalNotification alloc] init];
    NSDate *today = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
    NSLog(@"setting default value at 6PM");
    [dateComponents setHour:18];
    [dateComponents setMinute:0];
    [[NSUserDefaults standardUserDefaults]setInteger:18 forKey:kReminderHourSaved];
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:kReminderMinutesSaved];
    [self fireLocalNotifications:dateComponents];
}

- (void) scheduleNotificationsWithSavedSettings {
    self.localNotif = [[UILocalNotification alloc] init];
    
    NSDate *today = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
    NSInteger savedHour = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderHourSaved];
    NSInteger savedMins = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderMinutesSaved];
    
    if (savedHour && savedMins) {
        [dateComponents setHour:savedHour];
        [dateComponents setMinute:savedMins];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications]; //just to be sure, we are not firing multiple
    [self fireLocalNotifications:dateComponents];
}

- (void) fireLocalNotifications:(NSDateComponents *)dateComponents {
    self.localNotif.timeZone = [[NSCalendar currentCalendar] timeZone];
    self.localNotif.fireDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    self.localNotif.soundName = UILocalNotificationDefaultSoundName;
    self.localNotif.repeatInterval = NSDayCalendarUnit;
    self.localNotif.alertBody = @"Did you remember to enter your timesheet today?";
    self.localNotif.alertAction = NSLocalizedString(@"Trackerati", nil);
    self.localNotif.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotif];
}



@end
