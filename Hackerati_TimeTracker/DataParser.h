//
//  DataParser.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataParser : NSObject

+ (DataParser*) sharedManager;
- (void) startParseAndSaveForUser;

@end
