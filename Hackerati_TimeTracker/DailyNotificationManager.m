//
//  WeeklyNotificationManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "WeeklyNotificationManager.h"

@interface WeeklyNotificationManager ()

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
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *today = [NSDate date];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
        [dateComponents setHour:13];
        [dateComponents setMinute:20];
        localNotif.timeZone = [[NSCalendar currentCalendar] timeZone];
        localNotif.fireDate = [calendar dateFromComponents:dateComponents];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.repeatInterval = NSDayCalendarUnit;
        localNotif.alertBody = @"Did you remember to enter your timesheet today?";
        localNotif.alertAction = NSLocalizedString(@"Trackerati", nil);
        localNotif.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    
    return self;
}




@end
