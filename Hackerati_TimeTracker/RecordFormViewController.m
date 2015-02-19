//
//  RecordFormViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "RecordFormViewController.h"
#import "THDatePickerViewController.h"
#import "FireBaseManager.h"
#import "HConstants.h"
#import "LastSavedManager.h"
#import <QuartzCore/QuartzCore.h>
#import "DataParser.h"
#import "IQDropDownTextField.h"


@interface RecordFormViewController ()<THDatePickerDelegate,UITextViewDelegate,IQDropDownTextFieldDelegate>

@property (strong, nonatomic) THDatePickerViewController *datePicker;
@property (nonatomic, strong) NSDate * curDate;
@property (nonatomic, strong) NSDateFormatter * formatter;

@property (weak, nonatomic) IBOutlet UILabel *clientLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@property (weak, nonatomic) IBOutlet IQDropDownTextField *hourTextField;
@property (strong, nonatomic) Firebase *fireBase;
@property (nonatomic) BOOL isDatePickerShowing;

- (IBAction)submitRecordAction:(id)sender;
- (IBAction)typeButtonAction:(id)sender;
- (IBAction)statusButtonAction:(id)sender;
- (IBAction)dateButtonAction:(id)sender;

@end

@implementation RecordFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f/1.0f];
    self.detailContainerView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f/1.0f];
    
    self.commentTextView.layer.cornerRadius = 5.0f;
    self.commentTextView.clipsToBounds = YES;
    [self.commentTextView.layer setBorderWidth:0.5f];
    [self.commentTextView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    self.submitRecordButton.layer.cornerRadius = 5.0f;
    self.submitRecordButton.clipsToBounds = YES;
    [self.submitRecordButton.layer setBorderWidth:0.5f];
    [self.submitRecordButton.layer setBorderColor:[UIColor grayColor].CGColor];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MM/dd/yyyy"];
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.detailContainerView addGestureRecognizer:tap];
    
    if (self.isNewRecord) {
        self.title = @"New Record";
    } else {
        self.title = @"Edit Record";
    }
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    self.hourTextField.inputAccessoryView = toolbar;
    
    self.hourTextField.isOptionalDropDown = NO;
    [self.hourTextField setItemList:[NSArray arrayWithObjects:@"0.5",@"1.0",@"1.5",@"2.0",@"2.5",@"3.0",@"3.5",@"4.0",@"4.5",@"5.0",@"5.5",@"6.0",@"6.5",@"7.0",@"7.5",@"8.0",@"8.5",@"9.0",@"9.5",@"10.0", @"10.5",@"11.0",@"11.5",@"12.0",@"12.5",@"13.0",@"13.5",@"14.0",@"14.5",@"15.0",@"15.5",@"16.0",@"16.5",@"17.0",@"17.5",@"18.0",@"18.5",@"19.0",@"19.5",@"20.0",@"20.5",@"21.0",@"21.5",@"22.0",@"22.5",@"23.0",@"23.5",@"24.0",nil]];
    
}

-(void)doneClicked:(UIBarButtonItem*)button{
    [self.view endEditing:YES];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.isDatePickerShowing = NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.isDatePickerShowing = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view endEditing:YES];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.isDatePickerShowing = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isDatePickerShowing = NO;
    
    if (self.isNewRecord) {
        self.projectLabel.text = self.projectName;
        self.clientLabel.text = self.clientName;
        [self.dateButton setTitle:[self.formatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
        self.hourTextField.text = @"8.0";
        [self.statusButton setTitle:[HConstants KfullTimeEmployee] forState:UIControlStateNormal];
        [self.typeButton setTitle:[HConstants KbillableHour] forState:UIControlStateNormal];
        
        NSDictionary *lastSavedRecord = [[LastSavedManager sharedManager]getRecordForClient:self.clientLabel.text withProject:self.self.projectLabel.text];
        if ([lastSavedRecord objectForKey:[HConstants kComment]]) {
            self.commentTextView.text = [lastSavedRecord objectForKey:[HConstants kComment]];
        } else{
            self.commentTextView.text = nil;
        }
        
    } else{
        self.projectLabel.text = [self.existingRecord objectForKey:[HConstants kProject]];
        self.projectName = [self.existingRecord objectForKey:[HConstants kProject]];
        self.clientLabel.text = [self.existingRecord objectForKey:[HConstants kClient]];
        self.clientName = [self.existingRecord objectForKey:[HConstants kClient]];
        [self.dateButton setTitle:[self.existingRecord objectForKey:[HConstants kDate]] forState:UIControlStateNormal];
        self.hourTextField.text = [self.existingRecord objectForKey:[HConstants kHour]];
        if ([self.existingRecord objectForKey:[HConstants kStatus]] && [[self.existingRecord objectForKey:[HConstants kStatus]]isEqualToString:@"1"] ) {
            [self.statusButton setTitle:[HConstants KfullTimeEmployee] forState:UIControlStateNormal];
        } else{
            [self.statusButton setTitle:[HConstants KpartTimeEmployee] forState:UIControlStateNormal];
        }
        if ([self.existingRecord objectForKey:[HConstants kType]] && [[self.existingRecord objectForKey:[HConstants kType]]isEqualToString:@"1"] ) {
            [self.typeButton setTitle:[HConstants KbillableHour] forState:UIControlStateNormal];
        }else{
            [self.typeButton setTitle:[HConstants KunbillableHour] forState:UIControlStateNormal];
        }
        if ([self.existingRecord objectForKey:[HConstants kComment]]) {
            self.commentTextView.text = [self.existingRecord objectForKey:[HConstants kComment]];
        }
    }
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


- (IBAction)typeButtonAction:(id)sender {
    UIButton *typeButton = (UIButton*)sender;
    if ([typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]]){
        [typeButton setTitle:[HConstants KunbillableHour] forState:UIControlStateNormal];
    } else{
        [typeButton setTitle:[HConstants KbillableHour] forState:UIControlStateNormal];
    }
    
}

- (IBAction)statusButtonAction:(id)sender {
    UIButton *statusButton = (UIButton*)sender;
    if ([statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]]){
        [statusButton setTitle:[HConstants KpartTimeEmployee] forState:UIControlStateNormal];
    } else{
        [statusButton setTitle:[HConstants KfullTimeEmployee] forState:UIControlStateNormal];
    }

}

- (IBAction)dateButtonAction:(id)sender {
    if (self.isNewRecord && !self.isDatePickerShowing) {
        if(!self.datePicker)
            self.datePicker = [THDatePickerViewController datePicker];
        self.datePicker.date = self.curDate;
        self.datePicker.delegate = self;
        [self.datePicker setAllowClearDate:NO];
        [self.datePicker setClearAsToday:YES];
        [self.datePicker setAutoCloseOnSelectDate:YES];
        [self.datePicker setAllowSelectionOfSelectedDate:YES];
        [self.datePicker setDisableHistorySelection:NO];
        [self.datePicker setDisableFutureSelection:NO];
        [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
        [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
        [self.datePicker setCurrentDateColorSelected:[UIColor yellowColor]];
        
        [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
            int tmp = (arc4random() % 30)+1;
            return (tmp % 5 == 0);
        }];
        
        [self presentSemiViewController:self.datePicker withOptions:@{
                                                                      KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                      KNSemiModalOptionKeys.animationDuration : @(1.0),
                                                                      KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                      }];
    }
}

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    self.curDate = datePicker.date;
    [self.dateButton setTitle:[self.formatter stringFromDate:self.curDate] forState:UIControlStateNormal];
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    [self.dateButton setTitle:[self.formatter stringFromDate:selectedDate] forState:UIControlStateNormal];
}

- (IBAction)submitRecordAction:(id)sender {
    if (self.isNewRecord) {
        NSDictionary *history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
        if ([history objectForKey:self.dateButton.titleLabel.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this ?",self.dateButton.titleLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
        } else{
            [self checkDate];
        }
    }
    else {
        [self checkDate];
    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Send"]) {
        [self checkDate];
    } else if ([buttonTitle isEqualToString:@"Send Anyway"]) {
        [self sendData];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{

    [self.mainScrollView setContentOffset:CGPointMake(0, 150) animated:YES];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    BOOL reachedLimit = true;
    
    if ([[textView text] length] - range.length + text.length > 300)
        reachedLimit = false;
    return reachedLimit;
}

-(void)tapAction{
    [self.view endEditing:YES];
    [self.mainScrollView setContentOffset:CGPointMake(0, -64) animated:YES];
}

-(void)checkDate{
    
    NSDate *dateFromString = [self.formatter dateFromString:self.dateButton.titleLabel.text];
    int addDaysCount = 8;
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:addDaysCount];
    NSDate *cutOffDate = [[NSCalendar currentCalendar]
                          dateByAddingComponents:dateComponents
                          toDate:dateFromString options:0];
    
    if ([cutOffDate compare:[NSDate date]] == NSOrderedAscending) {
        NSLog(@"date1 is earlier than date2");
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Can not send record older than 7 days" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil]show];
    } else if ([dateFromString compare:[NSDate date]] == NSOrderedDescending){
        NSLog(@"date1 is later than date2");
        [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Entered future date. Do you still want to submit ?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Send Anyway" ,nil]show];
    } else {
        [self sendData];
    }

}

-(void)sendData{
    
    if ([self.hourTextField.text isEqualToString:@"0.0"]) {
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"You can not submit 0 hour" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
    }else{
        if (self.isNewRecord) {
            self.fireBase = [FireBaseManager recordURLsharedFireBase];
            if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
                [[self.fireBase childByAutoId] setValue:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kComment]:self.commentTextView.text,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0")}];
                [[LastSavedManager sharedManager] saveRecord:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0"),[HConstants kComment]:self.commentTextView.text}];
            } else{
                [[self.fireBase childByAutoId] setValue:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0")}];
                [[LastSavedManager sharedManager] saveRecord:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0")}];
            }
        } else{
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
            NSString *uniqueAddress = (NSString*)[self.existingRecord objectForKey:@"key"];
            self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records/%@",[HConstants kFireBaseURL],username,uniqueAddress]];
            if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
                [self.fireBase updateChildValues:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kComment]:self.commentTextView.text,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0")}];
                [[LastSavedManager sharedManager] saveRecord:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0"),[HConstants kComment]:self.commentTextView.text}];
            } else{
                [self.fireBase updateChildValues:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0"),[HConstants kComment]:@""}];
                [[LastSavedManager sharedManager] saveRecord:@{[HConstants kClient]:self.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants KfullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants KbillableHour]])?@"1":@"0"),[HConstants kComment]:@""}];
            }
    
        }
        [[DataParser sharedManager] getUserRecords];
        if (self.previousViewController && self.previousViewController.navigationController) {
            [self.previousViewController.navigationController popViewControllerAnimated:YES];
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    
}
@end
