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
@property (nonatomic, strong) NSMutableArray *projects;

-(id)init;
-(void)addProject:(Project*)project;
-(Project*)findProject:(NSString*)projectName;
-(void)deleteProject:(NSString*)projectName;
-(BOOL)isProjectsEmpty;


- (NSInteger)numberOfProjects;
-(Project*)projectAtIndex:(NSInteger)index;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
