//
//  LastSavedManager.m
//  trackerati-ios
//
//  Created by Ethan on 1/8/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "LastSavedManager.h"
#import "HConstants.h"


@implementation LastSavedManager

+ (LastSavedManager*)sharedManager{
    static LastSavedManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[LastSavedManager alloc]init];
    });
    return shareManager;
}

-(void)saveRecord:(Record*)record{
    NSData *archivedDataOfLastSavedRecordsArray = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kLastSavedRecord]];
    NSMutableArray *mutableLastSavedInfoArray;
    
    if (archivedDataOfLastSavedRecordsArray != nil) {
        mutableLastSavedInfoArray = [[NSKeyedUnarchiver unarchiveObjectWithData:archivedDataOfLastSavedRecordsArray] mutableCopy];
    }

    if (!mutableLastSavedInfoArray || [mutableLastSavedInfoArray count] == 0) {
        mutableLastSavedInfoArray = [NSMutableArray new];
        [mutableLastSavedInfoArray addObject:record];
    }
    else {
        //if the saved info array already had Records, check each record's client names and project names Ex) Hackerati, Internal. If matched, we remove that record and replace it with a new record last saved information
        NSMutableArray *recordsToDelete = [NSMutableArray array];
        for (Record *oldRecord in mutableLastSavedInfoArray) {
            if ([oldRecord.clientName isEqualToString:record.clientName] && [oldRecord.projectName isEqualToString:record.projectName]) {
                [recordsToDelete addObject:oldRecord];
            }
        };
        if (recordsToDelete.count > 0) {
            [mutableLastSavedInfoArray removeObjectsInArray:recordsToDelete];
            //this recordsToDelete logic is needed because we can't remove objects frmo mutableLastSavedArray while iterating
        }
        [mutableLastSavedInfoArray addObject:record];
    }

    NSData *lastSavedRecordsArrayData = [NSKeyedArchiver archivedDataWithRootObject:mutableLastSavedInfoArray];
    [[NSUserDefaults standardUserDefaults] setObject:lastSavedRecordsArrayData forKey:[HConstants kLastSavedRecord]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(Record*)getRecordForClient:(Client*)client withProject:(Project*)project{
    NSData *dataLastSavedRecords = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kLastSavedRecord]];
    __block Record* record = nil;
    NSArray* lastSavedInfo;
    
    if (dataLastSavedRecords) {
        lastSavedInfo = [NSKeyedUnarchiver unarchiveObjectWithData:dataLastSavedRecords];
        if (lastSavedInfo) {
            [lastSavedInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                Record *tempRecord = (Record *)obj;
                if ([tempRecord.clientName isEqualToString:client.clientName] && [tempRecord.projectName isEqualToString:project.projectName]) {
                    record = tempRecord;
                    *stop = YES;
                }
            }];
        }
        
    }
    return record;
}



@end
