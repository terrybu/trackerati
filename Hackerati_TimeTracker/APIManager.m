//
//  APIManager.m
//  trackerati-ios
//
//  Created by Sergey Morozov on 3/25/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "APIManager.h"
#import "HConstants.h"
#import "LastSavedManager.h"

@implementation APIManager

+ (APIManager*)api{
    static APIManager *apiManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiManager = [[APIManager alloc]init];
    });
    return apiManager;
}

-(void)submitDefaultRecord:(void (^)())completionHandler{
    Record * defaultRecord = [LastSavedManager.sharedManager getLastRecord];
    if(defaultRecord!=nil){
        //setting date to today's date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        defaultRecord.dateOfTheService = [formatter stringFromDate:[NSDate date]];
        [self submitRecord:defaultRecord completionHandler:completionHandler];
    }
    else if(completionHandler)
        completionHandler();
}

-(void)submitRecord:(Record*)record completionHandler:(void (^)())completionHandler{
    self.fireBase = [FireBaseManager recordURLsharedFireBase];
    [[self.fireBase childByAutoId ]
        setValue: @{[HConstants kClient]:record.clientName,
                    [HConstants kDate]:record.dateOfTheService,
                    [HConstants kHour]:record.hourOfTheService,
                    [HConstants kProject]:record.projectName,
                    [HConstants kComment]:record.commentOnService,
                    [HConstants kStatus]:record.statusOfUser,
                    [HConstants kType]:(record.typeOfService)}
     
        withCompletionBlock:^(NSError *error, Firebase *ref) {
            //updating local cache
            if(error == nil)
                [LastSavedManager.sharedManager saveRecord:(Record*)record];
            completionHandler();
        }
     ];
}

@end
