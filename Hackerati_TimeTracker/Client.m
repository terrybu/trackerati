//
//  Client.m
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "Client.h"

@interface Client ()

@property (nonatomic, strong) NSMutableArray *projects;

@end

@implementation Client

@synthesize projects;

-(id)init{
    self = [super init];
    if (self) {
        self.clientName = nil;
        self.projects = [[NSMutableArray alloc]init];
    }
    return self;
}
-(Project*)findProject:(NSString*)projectName{
    __block Project *project = nil;
    if (self.projects) {
        [self.projects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([obj isKindOfClass:[Project class]]) {
                Project *objProject = (Project*)obj;
                if ([[objProject projectName] isEqualToString:projectName]) {
                    project = objProject;
                    *stop = YES;
                }
            }
        }];
    }
    return project;
}

-(void)deleteProject:(NSString*)projectName{
    if (self.projects) {
        [self.projects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([obj isKindOfClass:[Project class]]) {
                Project *objProject = (Project*)obj;
                if ([[objProject projectName] isEqualToString:projectName]) {
                    [self.projects removeObjectAtIndex:idx];
                    *stop = YES;
                }
            }
        }];
    }
}

-(void)addProject:(Project*)project{
    
    if (!self.projects) {
        self.projects = [[NSMutableArray alloc]init];
        [self.projects addObject:project];
    } else {
        Project *newProject = [self findProject:project.projectName];
        if (newProject) {
            [self deleteProject:newProject.projectName];
            [self addProject:project];
        } else{
            [self.projects addObject:project];
        }
    }
}

-(BOOL)isProjectsEmpty{
    BOOL hasProject = YES;
    if (self.projects && [self.projects count] > 0) {
        hasProject = NO;
    }
    return hasProject;
}

- (NSInteger)numberOfProjects{
    NSInteger num = 0;
    if (self.projects) {
        num = [self.projects count];
    }
    return num;
}

-(Project*)projectAtIndex:(NSInteger)index{
    Project *project = nil;
    if (self.projects) {
        project = [self.projects objectAtIndex:index];
    }
    return project;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.clientName forKey:@"clientName"];
    [aCoder encodeObject:self.projects forKey:@"projects"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    NSString* clientName = [aDecoder decodeObjectForKey:@"clientName"];
    NSMutableArray* tProjects = [aDecoder decodeObjectForKey:@"projects"];
    self = [[Client alloc]init];
    self.clientName = clientName;
    self.projects = tProjects;
    return self;
}


@end
