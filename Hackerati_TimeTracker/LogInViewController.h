//
//  LoginViewController.h
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginManager.h"
#import "Reachability.h"
#import "DataParseManager.h"

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,DataParseManagerProtocol,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
