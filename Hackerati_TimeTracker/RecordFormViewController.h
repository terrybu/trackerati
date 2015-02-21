//
//  RecordFormViewController.h
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface RecordFormViewController : UIViewController

@property (copy, nonatomic) NSString *clientName;
@property (copy, nonatomic) NSString *projectName;
@property (nonatomic) BOOL isNewRecord;
@property (nonatomic, strong) Record *existingRecord;
@property (nonatomic, weak) UIViewController *previousViewController;

@end
