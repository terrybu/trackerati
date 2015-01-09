//
//  NewProjectViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/7/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "NewProjectViewController.h"
#import "HConstants.h"
#import <MCSwipeTableViewCell.h>
#import <Firebase/Firebase.h>

@interface NewProjectViewController () <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary *datas;
@property (strong, nonatomic) NSMutableDictionary *sectionInformation;
@property (strong, nonatomic) NSMutableDictionary *rowInformation;
@end

@implementation NewProjectViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sectionInformation = [[NSMutableDictionary alloc]init];
    self.rowInformation = [[NSMutableDictionary alloc]init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"Drag right to add";
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.datas = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kMasterClientList]];
        __block int count = 0;
        __weak typeof(self) weakSelf = self;
        [self.datas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            [weakSelf.sectionInformation setObject:obj forKey:[NSNumber numberWithInt:count]];
            [weakSelf.rowInformation setObject:key forKey:[NSNumber numberWithInt:count]];
            count++;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:section]];
    return [rows count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    cell.delegate =self;
    
    __weak typeof(self) weakSelf = self;
    
    UIColor *whiteColor = [UIColor whiteColor];
    UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
    
    [cell setSwipeGestureWithView:checkMark color:whiteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        
        NSDictionary* data = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KcurrentUserClientList]];
        NSMutableDictionary *mutableData = [[NSMutableDictionary alloc]initWithDictionary:data];
        NSString *client = [weakSelf.rowInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        NSString *project = [rows objectAtIndex:indexPath.row];
        
        BOOL alreadyPartofTheProject = NO;
        
        if (![mutableData objectForKey:client]) {
            [mutableData setObject:[[NSMutableArray alloc]initWithObjects:project,nil] forKey:client];
        } else {
            NSMutableArray *projects = [mutableData objectForKey:client];
            if (![projects containsObject:project]) {
                NSMutableArray *mutableProjects = [[NSMutableArray alloc]initWithArray:projects];
                [mutableProjects addObject:project];
                [mutableData setObject:mutableProjects forKey:client];
            } else{
                alreadyPartofTheProject = YES;
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:[HConstants KcurrentUserClientList]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        if (alreadyPartofTheProject) {
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"New Project" message:[NSString stringWithFormat:@"You are already part of %@.",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alerView show];
        } else{
            Firebase *fbase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@",[HConstants kFireBaseURL],client,project]];
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
            [[fbase childByAutoId] setValue:@{@"name":username}];
            
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"New Project" message:[NSString stringWithFormat:@"%@ Added",project] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alerView show];
        }
        
        
    }];
    
    NSArray *rows = [self.sectionInformation objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    cell.textLabel.text = [rows objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.rowInformation allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return (NSString*)[self.rowInformation objectForKey:[NSNumber numberWithInteger:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
