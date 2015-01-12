//
//  DataParser.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogInManager.h"

@protocol DataParserProtocol <NSObject>

-(void) loadData;
-(void) loginUnsuccessful;

@end

@interface DataParser : NSObject <LogInManagerProtocol>

@property (nonatomic, weak) id <DataParserProtocol> delegate;

+ (DataParser*) sharedManager;
- (void) loginSuccessful;
- (void) mannuallySetDelegate:(id<DataParserProtocol>)delegate;
- (void) getUserRecords;

@end
