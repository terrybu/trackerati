//
//  WeeklyNotificationManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "WeeklyNotificationManager.h"

@interface WeeklyNotificationManager ()

@property (strong, nonatomic) UILocalNotification *localNotificationMonday;
@property (strong, nonatomic) UILocalNotification *localNotificationTuesday;
@property (strong, nonatomic) UILocalNotification *localNotificationWednesday;
@property (strong, nonatomic) UILocalNotification *localNotificationThursday;
@property (strong, nonatomic) UILocalNotification *localNotificationFriday;

@end

@implementation WeeklyNotificationManager

+ (WeeklyNotificationManager*)sharedManager{
    static WeeklyNotificationManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[WeeklyNotificationManager alloc]init];
    });
    return shareManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *dateComponentsMonday = [[NSDateComponents alloc] init];
        dateComponentsMonday.weekday = 2; // sunday = 1 ... saturday = 7
        dateComponentsMonday.hour = 17;
        self.localNotificationMonday = [[UILocalNotification alloc]init];
        self.localNotificationMonday.timeZone = [[NSCalendar currentCalendar] timeZone];
        self.localNotificationMonday.repeatInterval = NSWeekCalendarUnit;
        self.localNotificationMonday.fireDate = [calendar dateFromComponents:dateComponentsMonday];
        self.localNotificationMonday.soundName = UILocalNotificationDefaultSoundName;
        self.localNotificationMonday.alertBody = @"Please enter your timesheet";
        self.localNotificationMonday.hasAction = YES;
        self.localNotificationMonday.alertAction = NSLocalizedString(@"Trackerati", nil);
        self.localNotificationMonday.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotificationMonday];
        
        NSDateComponents *dateComponentsTuesday = [[NSDateComponents alloc] init];
        dateComponentsTuesday.weekday = 3; // sunday = 1 ... saturday = 7
        dateComponentsTuesday.hour =17;
        self.localNotificationTuesday = [[UILocalNotification alloc]init];
        self.localNotificationTuesday.timeZone = [[NSCalendar currentCalendar] timeZone];
        self.localNotificationTuesday.repeatInterval = NSWeekCalendarUnit;
        self.localNotificationTuesday.fireDate = [calendar dateFromComponents:dateComponentsTuesday];
        self.localNotificationTuesday.soundName = UILocalNotificationDefaultSoundName;
        self.localNotificationTuesday.alertBody = @"Please enter your timesheet";
        self.localNotificationTuesday.hasAction = YES;
        self.localNotificationTuesday.alertAction = NSLocalizedString(@"Trackerati", nil);
        self.localNotificationTuesday.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotificationTuesday];
        
        NSDateComponents *dateComponentsWednesday = [[NSDateComponents alloc] init];
        dateComponentsWednesday.weekday = 4; // sunday = 1 ... saturday = 7
        dateComponentsWednesday.hour = 17;
        self.localNotificationWednesday = [[UILocalNotification alloc]init];
        self.localNotificationWednesday.timeZone = [[NSCalendar currentCalendar] timeZone];
        self.localNotificationWednesday.repeatInterval = NSWeekCalendarUnit;
        self.localNotificationWednesday.fireDate = [calendar dateFromComponents:dateComponentsWednesday];
        self.localNotificationWednesday.soundName = UILocalNotificationDefaultSoundName;
        self.localNotificationWednesday.alertBody = @"Please enter your timesheet";
        self.localNotificationWednesday.hasAction = YES;
        self.localNotificationWednesday.alertAction = NSLocalizedString(@"Trackerati", nil);
        self.localNotificationWednesday.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotificationWednesday];
        
        NSDateComponents *dateComponentsThursday = [[NSDateComponents alloc] init];
        dateComponentsThursday.weekday = 5; // sunday = 1 ... saturday = 7
        dateComponentsThursday.hour =17;
        self.localNotificationThursday = [[UILocalNotification alloc]init];
        self.localNotificationThursday.timeZone = [[NSCalendar currentCalendar] timeZone];
        self.localNotificationThursday.repeatInterval = NSWeekCalendarUnit;
        self.localNotificationThursday.fireDate = [calendar dateFromComponents:dateComponentsThursday];
        self.localNotificationThursday.soundName = UILocalNotificationDefaultSoundName;
        self.localNotificationThursday.alertBody = @"Please enter your timesheet";
        self.localNotificationThursday.hasAction = YES;
        self.localNotificationThursday.alertAction = NSLocalizedString(@"Trackerati", nil);
        self.localNotificationThursday.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotificationThursday];
        
        NSDateComponents *dateComponentsFriday = [[NSDateComponents alloc] init];
        dateComponentsFriday.weekday = 6; // sunday = 1 ... saturday = 7
        dateComponentsFriday.hour =17;
        self.localNotificationFriday = [[UILocalNotification alloc]init];
        self.localNotificationFriday.timeZone = [[NSCalendar currentCalendar] timeZone];
        self.localNotificationFriday.repeatInterval = NSWeekCalendarUnit;
        self.localNotificationFriday.fireDate = [calendar dateFromComponents:dateComponentsFriday];
        self.localNotificationFriday.soundName = UILocalNotificationDefaultSoundName;
        self.localNotificationFriday.alertBody = @"Please enter your timesheet";
        self.localNotificationFriday.hasAction = YES;
        self.localNotificationFriday.alertAction = NSLocalizedString(@"Trackerati", nil);
        self.localNotificationFriday.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotificationFriday];
    }
    
    return self;
}


@end
