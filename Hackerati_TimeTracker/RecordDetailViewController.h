//
//  RecordDetailViewController.h
//  trackerati-ios
//
//  Created by Ethan on 1/9/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"
#import "HistoryViewController.h"

@interface RecordDetailViewController : UIViewController

@property (nonatomic, strong) Record *record;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) HistoryViewController *historyViewController;


@end
