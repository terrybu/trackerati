//
//  NewClientProjectViewController.m
//  trackerati-ios
//
//  Created by Terry Bu on 2/19/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "AddClientProjectViewController.h"
#import "FireBaseManager.h"
#import "HConstants.h"

@interface AddClientProjectViewController () {
    NSMutableArray *autoCompleteClientNamesArray;
    UITableView *autocompleteTableView;
}


//might implement searchbar instead for future of client names
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;

@property (weak, nonatomic) IBOutlet UITextField *clientTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *projectTitleTextField;
@property (strong, nonatomic) Firebase *fireBase;

@end

@implementation AddClientProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Add New Client/Project";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(saveNewClientProjectAndPopVC)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:
                             CGRectMake(0, 200, self.view.frame.size.width * 0.6, self.view.frame.size.height) style:UITableViewStylePlain];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden = YES;
    [self.view addSubview:autocompleteTableView];
    
    autoCompleteClientNamesArray = [[NSMutableArray alloc]init];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    autocompleteTableView.hidden = NO;
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring
                 stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}



- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    [autoCompleteClientNamesArray removeAllObjects];
    for(NSString *curString in self.clientNames) {
        NSRange substringRange = [curString rangeOfString:substring options:NSCaseInsensitiveSearch];
        if (substringRange.location == 0) {
            [autoCompleteClientNamesArray addObject:curString];
        }
    }
    [autocompleteTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) saveNewClientProjectAndPopVC {
    
    NSString *clientName = self.clientTitleTextField.text;
    NSString *projectName = self.projectTitleTextField.text;
    if (([clientName isEqualToString:@""]) || ([projectName isEqualToString:@""])) {
        [[[UIAlertView alloc]initWithTitle:@"Please fill both fields" message:@"Either field can't be blank" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/",[HConstants kFireBaseURL], clientName, projectName]];
    
    [self runDataValidationAndSend];

}

- (void) runDataValidationAndSend {
    //we can do this validation in a different way without making a network call.
    //Since we already do a network call in the beginning, we can check all clients and projects
    
    [self.fireBase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value && [snapshot hasChildren]) {
            //if we got data back, then it means we can't write here
            [[[UIAlertView alloc]initWithTitle:@"Same project name exists" message:@"You cannot add this project name because an existing project was already found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        else if ([snapshot.value isEqual:[NSNull null]]){
            //if we don't get any data back, then we can write here
            [self sendPlaceholderToCreateNewClientProject];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void) sendPlaceholderToCreateNewClientProject {
    //we need to check if that project name under that client name already exists
    BOOL __block check = FALSE;
    Firebase *pathForPlaceholder =   [self.fireBase childByAutoId];
    NSDictionary *placeHolder = @{ @"name" : @"placeholder" };
    [pathForPlaceholder setValue:placeHolder];
}



#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return autoCompleteClientNamesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    cell.textLabel.text = [autoCompleteClientNamesArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.clientTitleTextField.text = selectedCell.textLabel.text;

    
}

@end
