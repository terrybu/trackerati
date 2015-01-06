//
//  Record.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client, Project;

@interface Record : NSManagedObject

@property (nonatomic, retain) NSNumber * hour;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Client *client;
@property (nonatomic, retain) Project *project;

@end
