//
//  LastSavedManager.h
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastSavedManager : NSObject

+ (LastSavedManager*)sharedManager;
-(void)saveRecord:(NSDictionary*)record;
-(NSDictionary*)getRecordForClient:(NSString*)client withProject:(NSString*)project;

@end
