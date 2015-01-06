//
//  LogInViewController.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "LogInViewController.h"
#import "FireBaseManager.h"
#import "DataParser.h"

@interface LogInViewController () 

@property (strong, nonatomic) NSMutableDictionary *datas;
@property (strong, nonatomic) GPPSignIn *googleSignIn;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.datas = [[NSMutableDictionary alloc]init];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"History" style:UIBarButtonItemStyleBordered target:self action:@selector(historyAction:)];
    
    
    
}


-(void) loginSuccessful{
    self.googleSignIn = [GPPSignIn sharedInstance];
    NSLog(@"%@\n",self.googleSignIn.userEmail);
    [[DataParser sharedManager] startParseAndSaveForUser];
}
-(void) loginUnsuccessful{
    
}


- (void) historyAction:(UIBarButtonItem*)barButton{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}


@end
