//
//  Project.h
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Project : NSObject

@property (nonatomic, strong) NSString *projectName;


-(id)init;

-(void)deleteUser:(NSString*)userName;

-(User*)findUser:(NSString*)userName;

-(void)addUser:(User*)user;

-(BOOL)isUsersEmpty;

- (void)encodeWithCoder:(NSCoder *)aCoder;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
