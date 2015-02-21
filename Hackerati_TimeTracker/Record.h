//
//  Record.h
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject

@property (nonatomic, strong) NSString *clientName;
@property (nonatomic, strong) NSString *projectName;
@property (nonatomic, strong) NSString *dateOfTheService;
@property (nonatomic, strong) NSString *hourOfTheService;
@property (nonatomic, strong) NSString *commentOnService;
@property (nonatomic, strong) NSString *statusOfUser;
@property (nonatomic, strong) NSString *typeOfService;
@property (nonatomic, strong) NSString *uniqueFireBaseIdentifier;

-(id)init;

@end
