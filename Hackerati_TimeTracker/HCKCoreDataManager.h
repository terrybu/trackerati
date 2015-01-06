//
//  HCKCoreDataManager.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface HCKCoreDataManager : NSObject

+ (instancetype)defaultStore;

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *privateQueueContext;

- (void) saveMainQueueContext;
- (void) savePrivateQueueContext;

@end
