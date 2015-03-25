//
//  LastSavedManager.h
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "Client.h"
#import "Project.h"

@interface LastSavedManager : NSObject

+ (LastSavedManager*)sharedManager;


//-(void)saveRecord:(NSDictionary*)record;
- (void)saveRecord:(Record *) record;

-(Record*)getRecordForClient:(Client*)client withProject:(Project*)project;

-(Record*)getLastRecord;

@end
