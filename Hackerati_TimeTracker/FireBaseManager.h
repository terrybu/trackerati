//
//  FireBaseManager.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@interface FireBaseManager : NSObject

+ (Firebase*)sharedFireBase;

@end
