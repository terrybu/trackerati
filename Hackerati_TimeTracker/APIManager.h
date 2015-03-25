//
//  APIManager.h
//  trackerati-ios
//
//  Created by Sergey Morozov on 3/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "FireBaseManager.h"

@interface APIManager : NSObject

@property (strong, nonatomic) Firebase *fireBase;

+ (APIManager*)api;

-(void)submitRecord:(Record*)record completionHandler:(void (^)())completionHandler;
-(void)submitDefaultRecord:(void (^)())completionHandler;

@end
