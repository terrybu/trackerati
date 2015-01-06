//
//  DataParser.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "DataParser.h"
#import "FireBaseManager.h"
#import "HCKCoreDataManager.h"

@interface DataParser ()

@property (nonatomic, strong) Firebase *ref;

@end

@implementation DataParser

+ (DataParser*) sharedManager{
    static DataParser *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DataParser alloc]init];
        _sharedManager.ref = [FireBaseManager sharedFireBase];
    });
    return _sharedManager;
}

- (void) startParseAndSaveForUser{
    [self.ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *context = [HCKCoreDataManager defaultStore].privateQueueContext;
            [context performBlockAndWait:^{
                
                NSDictionary* datas = snapshot.value;
                NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];
                if ([[[datas objectForKey:@"Users"]objectForKey:username]objectForKey:@"records"] && [[[[datas objectForKey:@"Users"]objectForKey:username]objectForKey:@"records"] isKindOfClass:[NSArray class]]) {
                    NSArray *records = [[[datas objectForKey:@"Users"]objectForKey:username]objectForKey:@"records"];
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                        
                    }];
                }
                
            }];
        });
    }];
}

@end
