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
#import "DataParseManager.h"

@interface AddClientProjectViewController () {
    NSMutableArray *autoCompleteClientNamesArray;
}

@property (weak, nonatomic) IBOutlet UITextField *clientTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *projectTitleTextField;
@property (strong, nonatomic) Firebase *fireBase;

@end

@implementation AddClientProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"New Project";
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveNewClientProjectAndPopVC)];
    self.navigationItem.rightBarButtonItem = plusButton;
    
    self.autoCompleteTableview.scrollEnabled = YES;
    self.autoCompleteTableview.hidden = YES;
    [self.view addSubview:self.autoCompleteTableview];
    
    autoCompleteClientNamesArray = [[NSMutableArray alloc]init];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    self.autoCompleteTableview.hidden = NO;
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
    [self.autoCompleteTableview reloadData];
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
            //if we don't get any data back, then we can safely write here to this path
            [self sendPlaceholderToCreateNewClientProject];
        }
    }];
}



- (void) sendPlaceholderToCreateNewClientProject {
    //we need to check if that project name under that client name already exists
    Firebase *pathForPlaceholder =   [self.fireBase childByAutoId];
    NSDictionary *placeHolder = @{ @"name" : @"placeholder" };
    [pathForPlaceholder setValue:placeHolder withCompletionBlock:^(NSError *error, Firebase *ref) {
        [[DataParseManager sharedManager]getAllClientsAndProjectsDataFromFireBaseAndSynchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
