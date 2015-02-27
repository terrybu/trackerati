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
        self.localNotif = [[UILocalNotification alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *today = [NSDate date];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
        [dateComponents setHour:13];
        [dateComponents setMinute:20];
        self.localNotif.timeZone = [[NSCalendar currentCalendar] timeZone];
        self.localNotif.fireDate = [calendar dateFromComponents:dateComponents];
        self.localNotif.soundName = UILocalNotificationDefaultSoundName;
        self.localNotif.repeatInterval = NSDayCalendarUnit;
        self.localNotif.alertBody = @"Did you remember to enter your timesheet today?";
        self.localNotif.alertAction = NSLocalizedString(@"Trackerati", nil);
        self.localNotif.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotif];
    }
    
    return self;
}




@end
