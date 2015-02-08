//
//  DataParseManager.h
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogInManager.h"

@protocol DataParseManagerProtocol <NSObject>

-(void) loadData;
-(void) loginUnsuccessful;

@end

@interface DataParseManager : NSObject <LogInManagerProtocol>

@property (nonatomic, weak) id <DataParseManagerProtocol> delegate;

+ (DataParseManager*) sharedManager;
- (void) loginSuccessful;
- (void) mannuallySetDelegate:(id<DataParseManagerProtocol>)delegate;
- (void) getUserRecords;

@end
