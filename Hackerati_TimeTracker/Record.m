//
//  Record.m
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "Record.h"

@implementation Record

-(id)init{
    self = [super init];
    if (self) {
        self.clientName = nil;
        self.projectName = nil;
        self.dateOfTheService = nil;
        self.hourOfTheService = nil;
        self.commentOnService = nil;
        self.statusOfUser = nil;
        self.typeOfService = nil;
        self.uniqueFireBaseIdentifier = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.clientName forKey:@"clientName"];
    [aCoder encodeObject:self.projectName forKey:@"projectName"];
    [aCoder encodeObject:self.dateOfTheService forKey:@"dateOfTheService"];
    [aCoder encodeObject:self.hourOfTheService forKey:@"hourOfTheService"];
    [aCoder encodeObject:self.commentOnService forKey:@"commentOnService"];
    [aCoder encodeObject:self.statusOfUser forKey:@"statusOfUser"];
    [aCoder encodeObject:self.typeOfService forKey:@"typeOfService"];
    [aCoder encodeObject:self.typeOfService forKey:@"firebaseUniqueKey"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    NSString* clientName = [aDecoder decodeObjectForKey:@"clientName"];
    NSString* projectName = [aDecoder decodeObjectForKey:@"projectName"];
    NSString* dateOfTheService = [aDecoder decodeObjectForKey:@"dateOfTheService"];
    NSString* hourOfTheService = [aDecoder decodeObjectForKey:@"hourOfTheService"];
    NSString* commentOnService = [aDecoder decodeObjectForKey:@"commentOnService"];
    NSString* statusOfUser = [aDecoder decodeObjectForKey:@"statusOfUser"];
    NSString* typeOfService = [aDecoder decodeObjectForKey:@"typeOfService"];
    NSString* firebaseUniqueKey = [aDecoder decodeObjectForKey:@"firebaseUniqueKey"];
    self = [[Record alloc]init];
    self.clientName = clientName;
    self.projectName = projectName;
    self.dateOfTheService = dateOfTheService;
    self.hourOfTheService = hourOfTheService;
    self.commentOnService = commentOnService;
    self.statusOfUser = statusOfUser;
    self.typeOfService = typeOfService;
    self.uniqueFireBaseIdentifier = firebaseUniqueKey;
    return self;
}

@end
