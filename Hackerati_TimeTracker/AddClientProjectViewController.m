//
//  NewClientProjectViewController.m
//  trackerati-ios
//
//  Created by Terry Bu on 2/19/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "AddClientProjectViewController.h"

@interface AddClientProjectViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;

@property (weak, nonatomic) IBOutlet UITextField *projectTitleTextField;

@end

@implementation AddClientProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNewClientProjectAndPop)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) saveNewClientProjectAndPop {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
