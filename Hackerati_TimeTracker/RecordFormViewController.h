//
//  RecordFormViewController.h
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"
#import "Client.h"
#import "Project.h"

@interface RecordFormViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Record *existingRecord;
@property (nonatomic, weak) UIViewController *previousViewController;
@property (nonatomic) BOOL isNewRecord;
@property (nonatomic, strong) Client *client;
@property (nonatomic, strong) Project *project;

@end
