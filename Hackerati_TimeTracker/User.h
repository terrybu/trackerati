//
//  User.h
//  trackerati-ios
//
//  Created by Ethan on 1/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic ,strong) NSString *userName;
@property (nonatomic, strong) NSString *uniqueFireBaseIdentifier;

-(id)init;

@end
