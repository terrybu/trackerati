//
//  Project.m
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "Project.h"

@interface Project ()

@property (nonatomic, strong) NSMutableArray *users;

@end

@implementation Project

@synthesize users;

-(id)init{
    self = [super init];
    if (self) {
        self.projectName = nil;
        self.users = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)addUser:(User*)user{
    if (!self.users) {
        self.users = [[NSMutableArray alloc]init];
    }
    [self.users addObject:user];
}

-(void)deleteUser:(NSString*)userName{
    if (self.users) {
        [self.users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([obj isKindOfClass:[User class]]) {
                User *objUser = (User*)obj;
                if ([[objUser userName] isEqualToString:userName]) {
                    [self.users removeObjectAtIndex:idx];
                    *stop = YES;
                }
            }
        }];
    }
}

-(User*)findUser:(NSString*)userName{
    __block User *user = nil;
    if (self.users) {
        [self.users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([obj isKindOfClass:[User class]]) {
                User *objUser = (User*)obj;
                if ([[objUser userName] isEqualToString:userName]) {
                    user = objUser;
                    *stop = YES;
                }
            }
        }];
    }
    return user;
}

-(BOOL)isUsersEmpty{
    BOOL hasUsers = YES;
    if (self.users && [self.users count] > 0) {
        hasUsers = NO;
    }
    return hasUsers;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.projectName forKey:@"projectName"];
    [aCoder encodeObject:self.users forKey:@"users"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    NSString* projectName = [aDecoder decodeObjectForKey:@"projectName"];
    NSMutableArray* tUsers = [aDecoder decodeObjectForKey:@"users"];
    self = [[Project alloc]init];
    self.projectName = projectName;
    self.users = tUsers;
    return self;
}

@end
