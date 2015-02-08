//
//  User.m
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "User.h"

@interface User ()

@end

@implementation User

-(id)init{
    self = [super init];
    if (self) {
        self.userName = nil;
        self.uniqueFireBaseIdentifier = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.uniqueFireBaseIdentifier forKey:@"uniqueFireBaseIdentifier"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    NSString* userName = [aDecoder decodeObjectForKey:@"userName"];
    NSString* uniqueFireBaseIdentifier = [aDecoder decodeObjectForKey:@"uniqueFireBaseIdentifier"];
    self = [[User alloc]init];
    self.userName = userName;
    self.uniqueFireBaseIdentifier = uniqueFireBaseIdentifier;
    return self;
}

@end
