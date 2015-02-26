//
//  DataParseManager.h
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogInManager.h"
#import "FireBaseManager.h"

@protocol DataParseManagerProtocol <NSObject>

-(void) loadData;
//-(void) loginSuccessful;
-(void) loginUnsuccessful;
-(void) userRecordsDataReceived;

@end

@interface DataParseManager : NSObject <LogInManagerProtocol>

@property (nonatomic, weak) id <DataParseManagerProtocol> delegate;
@property (nonatomic, strong) Firebase *records;

+ (DataParseManager*) sharedManager;
- (void) getAllDataFromFireBaseAfterLoginSuccess;
- (void) getAllClientsAndProjectsDataFromFireBaseAndSynchronize;
- (void) manuallySetDelegate:(id<DataParseManagerProtocol>)delegate;
- (void) getUserRecords;


@end
