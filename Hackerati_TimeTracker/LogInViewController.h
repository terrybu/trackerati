//
//  LogInViewController.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogInManager.h"
#import "Reachability.h"
#import "DataParser.h"

@interface LogInViewController : UIViewController < UITableViewDataSource, UITableViewDelegate,DataParserProtocol,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
