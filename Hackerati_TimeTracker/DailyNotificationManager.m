//
//  WeeklyNotificationManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "DailyNotificationManager.h"
#import "HConstants.h"
#import "AppDelegate.h"
#import "HConstants.h"
#import "LastSavedManager.h"

@interface DailyNotificationManager ()

@end

typedef NS_ENUM(NSInteger, WeekDayType) {
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday
};

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
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //clear out all and startover from scratch every time.
    //if you are not careful about clearing out between saves, you will have multiple notifs firing on top of each other

    bool remindersOn = [[NSUserDefaults standardUserDefaults]boolForKey:kRemindersOn];
    if (remindersOn) {
        self.localNotif = [[UILocalNotification alloc] init];
        [self scheduleNotificationsWithSavedSettings];
    }
    else if (remindersOn == NO){
        bool ranAppBefore = [[NSUserDefaults standardUserDefaults]boolForKey:kRanAppBeforeCheck];
        if (ranAppBefore) {
            NSLog(@"User had reminders turned off in settings");
        }
        else {
            NSLog(@"this is first time we are running the app - turn on daily reminder by default");
            self.localNotif = [[UILocalNotification alloc] init];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kRemindersOn];
            [self firstTimeRunSettings];
        }
    }
}

- (void) firstTimeRunSettings {
    NSLog(@"setting daily reminder at 6PM by default for first run");
    [self fireNotificationsForAllWeekDays:18 minute:0];
    [[NSUserDefaults standardUserDefaults]setInteger:18 forKey:kReminderHourSaved];
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:kReminderMinutesSaved];
}

- (void) scheduleNotificationsWithSavedSettings {
    NSInteger savedHour = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderHourSaved];
    NSInteger savedMins = [[NSUserDefaults standardUserDefaults]integerForKey:kReminderMinutesSaved];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];         //just to be sure, we are not firing multiple
    [self fireNotificationsForAllWeekDays:savedHour minute:savedMins];
}

- (void) fireNotificationsForAllWeekDays: (NSInteger) hour minute: (NSInteger) minute {
    [self fireNotificationForDay:Monday hour:hour minute:minute];
    [self fireNotificationForDay:Tuesday hour:hour minute:minute];
    [self fireNotificationForDay:Wednesday hour:hour minute:minute];
    [self fireNotificationForDay:Thursday hour:hour minute:minute];
    [self fireNotificationForDay:Friday hour:hour minute:minute];
}



#pragma mark Refactored Methods
- (void) fireNotificationForDay: (WeekDayType) day hour: (NSInteger) hour minute: (NSInteger) minute {
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];

    switch (day) {
        //dates below are arbitrary. They just need to be some point in the past that corresponds to that weekday.
        //when we repeat by weekly interval, it will hit us in the right times in the future
        case Monday: {
            [self setDateComponents:dateComponents year:2015 month:2 day:23 hour:hour minute:minute];
            break;
        }
        case Tuesday: {
            [self setDateComponents:dateComponents year:2015 month:2 day:24 hour:hour minute:minute];
            break;
        }
        case Wednesday: {
            [self setDateComponents:dateComponents year:2015 month:2 day:25 hour:hour minute:minute];
            break;
        }
        case Thursday: {
            [self setDateComponents:dateComponents year:2015 month:2 day:26 hour:hour minute:minute];
            break;
        }
        case Friday: {
            [self setDateComponents:dateComponents year:2015 month:2 day:27 hour:hour minute:minute];
            break;
        }
        default:
            break;
    }
    [self fireThisNotificationWeekly:dateComponents];
}

- (void) setDateComponents: (NSDateComponents *) dateComponents year: (NSInteger) year month:(NSInteger) month day:(NSInteger) day hour:(NSInteger) hour minute:(NSInteger) minute {
    [dateComponents setYear:year];
    [dateComponents setMonth:month];
    [dateComponents setDay:day];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
}


- (void) fireThisNotificationWeekly:(NSDateComponents *)dateComponents {
    self.localNotif.timeZone = [[NSCalendar currentCalendar] timeZone];
    self.localNotif.fireDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    self.localNotif.soundName = UILocalNotificationDefaultSoundName;
    self.localNotif.repeatInterval = NSWeekCalendarUnit;
    self.localNotif.alertBody = [self composeNotifMessage];
    self.localNotif.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    if([AppDelegate.globalDelegate isOS8])
        self.localNotif.category = [HConstants kNotificationCategory];
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotif];
}

- (NSString*) composeNotifMessage{
    NSString* message;
    Record* record = [LastSavedManager.sharedManager getLastRecord];
    if(record != nil && [AppDelegate.globalDelegate isOS8])
        message = [NSString stringWithFormat:@"Did you work @ %@ on %@ project for %@ hours today?", record.clientName, record.projectName, record.hourOfTheService];
    else {
        message = @"Did you remember to log your time today?";
    }
    return message;
}



@end
