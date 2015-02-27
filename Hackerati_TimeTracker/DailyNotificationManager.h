//
//  DailyNotificationManager.h
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DailyNotificationManager : NSObject

+ (DailyNotificationManager*)sharedManager;

@property (nonatomic, strong) UILocalNotification *localNotif;

- (void) refreshNotificationsSettings;

@end
