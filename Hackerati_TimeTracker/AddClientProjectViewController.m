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


//might implement searchbar instead for future
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
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Confirm Add" style:UIBarButtonItemStyleDone target:self action:@selector(saveNewClientProjectAndPopVC)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.confirmButton.layer.cornerRadius = 5.0f;
    self.confirmButton.clipsToBounds = YES;
    [self.confirmButton.layer setBorderWidth:0.5f];
    [self.confirmButton.layer setBorderColor:[UIColor grayColor].CGColor];
    
    autocompleteTableView = [[UITableView alloc] initWithFrame:
                             CGRectMake(0, 200, self.view.frame.size.width, 120) style:UITableViewStylePlain];
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
    
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Projects/%@/%@/",[HConstants kFireBaseURL], clientName, projectName]];
    
    Firebase *pathForPlaceholder =   [self.fireBase childByAutoId];
    NSDictionary *placeHolder = @{ @"name" : @"placeholder" };
    [pathForPlaceholder setValue:placeHolder];
    
    [self.navigationController popViewControllerAnimated:YES];
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
