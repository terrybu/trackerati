//
//  Client.h
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"

@interface Client : NSObject <NSCoding>

@property (nonatomic, strong) NSString *clientName;


-(id)init;

-(void)addProject:(Project*)project;

-(Project*)findProject:(NSString*)projectName;

-(void)deleteProject:(NSString*)projectName;

-(BOOL)isProjectsEmpty;

- (void)encodeWithCoder:(NSCoder *)aCoder;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSInteger)numberOfProjects;

-(Project*)projectAtIndex:(NSInteger)index;

@end
