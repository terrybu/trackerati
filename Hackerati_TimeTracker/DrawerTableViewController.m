//
//  JVLeftDrawerTableViewController.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "DrawerTableViewController.h"
#import "DrawerCell.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "HistoryViewController.h"
#import "HConstants.h"

typedef NS_ENUM(NSInteger, CellIndexType) {
    CellIndexTypeHome,
    CellIndexTypeHistory,
    CellIndexTypeLogout
};

static const CGFloat kJVTableViewTopInset = 80.0;

@interface DrawerTableViewController ()

@end

@implementation DrawerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);
    self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView registerNib:[UINib nibWithNibName:kCellNibName bundle:nil] forCellReuseIdentifier:kCellReuseIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:CellIndexTypeHome inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DrawerCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kCellNibName owner:self options:nil];
        cell = (DrawerCell *)[nib objectAtIndex:0];
    }
    
    switch (indexPath.row) {
        case CellIndexTypeHome: {
            cell.titleLabel.text = @"Home";
            cell.iconImageView.image = [[UIImage imageNamed:@"IconHome"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        }
        case CellIndexTypeHistory: {
            cell.titleLabel.text = @"History";
            cell.iconImageView.image = [[UIImage imageNamed:@"IconCalendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        }
        case CellIndexTypeLogout: {
            cell.titleLabel.text = @"Log Out";
            cell.iconImageView.image = [[UIImage imageNamed:@"IconLogoutPerson"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *destinationNavController = nil;
    
    if(indexPath.row == CellIndexTypeHome) {
        destinationNavController = [[AppDelegate globalDelegate].controllersDictionary objectForKey:kHomeNavControllerKey];
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationNavController];
    }
    else if (indexPath.row == CellIndexTypeHistory) {
        destinationNavController = [[AppDelegate globalDelegate].controllersDictionary objectForKey:kHistoryNavControllerKey];
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationNavController];
    }
    else if (indexPath.row == CellIndexTypeLogout) {
        [self logOutAction];
        //we redirect them to home
        destinationNavController = [[AppDelegate globalDelegate].controllersDictionary objectForKey:kHomeNavControllerKey];
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationNavController];
    }
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)logOutAction{
    [[LoginManager sharedManager]logOut];
    [LoginManager setLoggedOut:YES];
    [DataParseManager sharedManager].records = nil;
    
    //this reloading is needed because without it, when we log out from home screen, old projects still show up on the tableview of login View Controller
    [self loginRefresh];
}

- (void) loginRefresh {
    UINavigationController *homeNav = [[AppDelegate globalDelegate].controllersDictionary objectForKey:kHomeNavControllerKey];
    LoginViewController *lvc = (LoginViewController *) homeNav.viewControllers[0];
    [lvc reloadLocalCacheData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
