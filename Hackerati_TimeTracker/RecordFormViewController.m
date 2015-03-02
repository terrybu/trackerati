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
#import "DataParseManager.h"
#import "IQDropDownTextField.h"
#import "RecordDetailViewController.h"
#import "Record.h"

static NSString* const placeHolderForTextView =  @"Tap out while typing to scroll page back up";

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
    self.commentTextView.delegate = self;
    self.commentTextView.text = placeHolderForTextView;
    self.commentTextView.textColor = [UIColor lightGrayColor]; //optional
    
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
    
    [self setUpDropDownToolbarForHoursOnRecord];
}

- (void)setUpDropDownToolbarForHoursOnRecord {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    buttonDone.tintColor = [UIColor whiteColor];
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    self.hourTextField.inputAccessoryView = toolbar;
    self.hourTextField.isOptionalDropDown = NO;
    NSArray *arrayOfHourOptions = [NSArray arrayWithObjects:@"0.5",@"1.0",@"1.5",@"2.0",@"2.5",@"3.0",@"3.5",@"4.0",@"4.5",@"5.0",@"5.5",@"6.0",@"6.5",@"7.0",@"7.5",@"8.0",@"8.5",@"9.0",@"9.5",@"10.0", @"10.5",@"11.0",@"11.5",@"12.0",@"12.5",@"13.0",@"13.5",@"14.0",@"14.5",@"15.0",@"15.5",@"16.0",@"16.5",@"17.0",@"17.5",@"18.0",@"18.5",@"19.0",@"19.5",@"20.0",@"20.5",@"21.0",@"21.5",@"22.0",@"22.5",@"23.0",@"23.5",@"24.0",nil];
    [self.hourTextField setItemList:arrayOfHourOptions];
    
    if (self.isNewRecord) {
    //Set hour of service dropdown default to last saved
    Record *lastSavedRecord = [[LastSavedManager sharedManager]getRecordForClient:self.client withProject:self.project];
        if (lastSavedRecord != nil && lastSavedRecord.hourOfTheService) {
            [self.hourTextField setSelectedRow:[arrayOfHourOptions indexOfObject:lastSavedRecord.hourOfTheService]];
        }
        else {
            //when it's a new record with new project/client, defaulting to 8
            [self.hourTextField setSelectedRow:[arrayOfHourOptions indexOfObject:@"8.0"]];
        }
    }
    else {
        //If we are dealing with Edit screen, then we need to set it to what the existing record is saying
        [self.hourTextField setSelectedRow:[arrayOfHourOptions indexOfObject:self.existingRecord.hourOfTheService]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isDatePickerShowing = NO;
    
    if (self.isNewRecord) {
        self.clientLabel.text = self.client.clientName;
        self.projectLabel.text = self.project.projectName;
        [self.dateButton setTitle:[self.formatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
        [self.statusButton setTitle:[HConstants kFullTimeEmployee] forState:UIControlStateNormal];
        [self.typeButton setTitle:[HConstants kBillableHour] forState:UIControlStateNormal];
        self.hourTextField.text = @"8.0";
        [self displayUserInterfaceBasedOnLastSavedRecord];
    }
    else{
        //if it's an existing record for Edit screen
        self.projectLabel.text = self.existingRecord.projectName;
        self.clientLabel.text = self.existingRecord.clientName;
        [self.dateButton setTitle:self.existingRecord.dateOfTheService forState:UIControlStateNormal];
        self.hourTextField.text = self.existingRecord.hourOfTheService;
        if (self.existingRecord.statusOfUser && [self.existingRecord.statusOfUser isEqualToString:@"1"] ) {
            [self.statusButton setTitle:[HConstants kFullTimeEmployee] forState:UIControlStateNormal];
        } else{
            [self.statusButton setTitle:[HConstants kPartTimeEmployee] forState:UIControlStateNormal];
        }
        
        if (self.existingRecord.typeOfService && [self.existingRecord.typeOfService isEqualToString:@"1"] ) {
            [self.typeButton setTitle:[HConstants kBillableHour] forState:UIControlStateNormal];
        }else{
            [self.typeButton setTitle:[HConstants kUnbillableHour] forState:UIControlStateNormal];
        }
        
        if (self.existingRecord.commentOnService) {
            self.commentTextView.text = self.existingRecord.commentOnService;
        }
        
    }
}

- (void) displayUserInterfaceBasedOnLastSavedRecord {
    Record *lastSavedRecord = [[LastSavedManager sharedManager]getRecordForClient:self.client withProject:self.project];
    if (lastSavedRecord) {
        if (lastSavedRecord.statusOfUser) {
            if ([lastSavedRecord.statusOfUser isEqualToString:@"1"])
                [self.statusButton setTitle:[HConstants kFullTimeEmployee] forState:UIControlStateNormal];
            else
                [self.statusButton setTitle:[HConstants kPartTimeEmployee] forState:UIControlStateNormal];
            
        }
        if (lastSavedRecord.typeOfService) {
            if ([lastSavedRecord.typeOfService isEqualToString:@"1"])
                [self.typeButton setTitle:[HConstants kBillableHour] forState:UIControlStateNormal];
            else
                [self.typeButton setTitle:[HConstants kUnbillableHour] forState:UIControlStateNormal];
        }
        if (lastSavedRecord.hourOfTheService) {
            self.hourTextField.text = lastSavedRecord.hourOfTheService;
        }
        
        if (lastSavedRecord.commentOnService && ![lastSavedRecord.commentOnService isEqualToString:@""]) {
            self.commentTextView.text = lastSavedRecord.commentOnService;
        }
        else{
            self.commentTextView.text = placeHolderForTextView;
        }
    }
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



#pragma mark TextView Delegate Methods

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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeHolderForTextView]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeHolderForTextView;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)typeButtonAction:(id)sender {
    UIButton *typeButton = (UIButton*)sender;
    if ([typeButton.titleLabel.text isEqualToString:[HConstants kBillableHour]]){
        [typeButton setTitle:[HConstants kUnbillableHour] forState:UIControlStateNormal];
    } else{
        [typeButton setTitle:[HConstants kBillableHour] forState:UIControlStateNormal];
    }
    
}

- (IBAction)statusButtonAction:(id)sender {
    UIButton *statusButton = (UIButton*)sender;
    if ([statusButton.titleLabel.text isEqualToString:[HConstants kFullTimeEmployee]]){
        [statusButton setTitle:[HConstants kPartTimeEmployee] forState:UIControlStateNormal];
    } else{
        [statusButton setTitle:[HConstants kFullTimeEmployee] forState:UIControlStateNormal];
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
        NSData *currentUserRecordsData = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kSanitizedCurrentUserRecords]];
        NSDictionary* currentUserRecordsDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:currentUserRecordsData];
        if ([currentUserRecordsDictionary objectForKey:self.dateButton.titleLabel.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this?",self.dateButton.titleLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send Anyway", nil] show];
        }
        else{
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
        [self submitRecord];
    }
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
//        NSLog(@"date1 is earlier than date2");
//        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Can not send record older than 7 days" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles: nil]show];
        //another prevention logic for not allowing users to post record that's older than 7 day

        [self submitRecord];
    }
    else if ([dateFromString compare:[NSDate date]] == NSOrderedDescending){
        NSLog(@"date1 is later than date2");
        [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Entered future date. Do you still want to submit ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send Anyway" ,nil]show];
    }
    else {
        [self submitRecord];
    }

}

- (void)saveLastRecord {
    Record *newRecord = [[Record alloc]init];
    newRecord.clientName = self.client.clientName;
    newRecord.projectName = self.project.projectName;
    newRecord.dateOfTheService = self.dateButton.titleLabel.text;
    newRecord.hourOfTheService = self.hourTextField.text;
    newRecord.statusOfUser = ([self.statusButton.titleLabel.text isEqualToString:[HConstants kFullTimeEmployee]])?@"1":@"0";
    newRecord.typeOfService = ([self.typeButton.titleLabel.text isEqualToString:[HConstants kBillableHour]])?@"1":@"0";
    newRecord.commentOnService = self.commentTextView.text ? self.commentTextView.text : nil;
    [[LastSavedManager sharedManager] saveRecord:newRecord];
}

-(void)submitRecord{
    if ([self.commentTextView.text isEqualToString: placeHolderForTextView])
        self.commentTextView.text = nil;
    
    if ([self.hourTextField.text isEqualToString:@"0.0"]) {
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"You can not submit 0 hour" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
        return;
    }
    
    if (self.isNewRecord) {
        self.fireBase = [FireBaseManager recordURLsharedFireBase];
        if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
            [[self.fireBase childByAutoId] setValue:@{[HConstants kClient]:self.client.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.project.projectName,[HConstants kComment]:self.commentTextView.text,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants kFullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants kBillableHour]])?@"1":@"0")}];
        }
        else{
            //if we didn't have any comments, we send to Firebase a little differently without comments key
            [[self.fireBase childByAutoId] setValue:@{[HConstants kClient]:self.client.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.project.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants kFullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants kBillableHour]])?@"1":@"0")}];
        }
    }
    else{
        //it's not new record, we are submitting edits
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kCurrentUser]];
        NSString *uniqueAddress = self.existingRecord.uniqueFireBaseIdentifier;
        self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records/%@",[HConstants kFireBaseURL],username,uniqueAddress]];
        if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
            [self.fireBase updateChildValues:@{[HConstants kClient]:self.client.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.project.projectName,[HConstants kComment]:self.commentTextView.text,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants kFullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants kBillableHour]])?@"1":@"0")}];
        }
        else{
            //no comments, handle differently by clearing out key under comments
            [self.fireBase updateChildValues:@{[HConstants kClient]:self.client.clientName,[HConstants kDate]:self.dateButton.titleLabel.text,[HConstants kHour]:self.hourTextField.text,[HConstants kProject]:self.project.projectName,[HConstants kStatus]:(([self.statusButton.titleLabel.text isEqualToString:[HConstants kFullTimeEmployee]])?@"1":@"0"),[HConstants kType]:(([self.typeButton.titleLabel.text isEqualToString:[HConstants kBillableHour]])?@"1":@"0"),[HConstants kComment]:@""}];
        }
    }
    [self saveLastRecord];
    [[DataParseManager sharedManager] getUserRecords];
    
    [self resetUI];
}

- (void) resetUI {
    if (self.previousViewController && self.previousViewController.navigationController) {
        if ([self.previousViewController isKindOfClass:[RecordDetailViewController class]]) {
            //a temporary solution to show some Record detail information for previous view controller after EDIT
            //Ethan originally used LastSavedManager to do this - but with Record model integration, some of that code needed to change
            RecordDetailViewController *recordDetailVC = (RecordDetailViewController *) self.previousViewController;
            Record *tempRecordForRecordDetail = [[Record alloc]init];
            tempRecordForRecordDetail.clientName = self.client.clientName;
            tempRecordForRecordDetail.projectName = self.project.projectName;
            tempRecordForRecordDetail.uniqueFireBaseIdentifier = self.existingRecord.uniqueFireBaseIdentifier;
            tempRecordForRecordDetail.dateOfTheService = self.dateButton.titleLabel.text;
            tempRecordForRecordDetail.hourOfTheService = self.hourTextField.text;
            tempRecordForRecordDetail.commentOnService = self.commentTextView.text;
            tempRecordForRecordDetail.statusOfUser = ([self.statusButton.titleLabel.text isEqualToString:[HConstants kFullTimeEmployee]])?@"1":@"0";
            tempRecordForRecordDetail.typeOfService = ([self.typeButton.titleLabel.text isEqualToString:[HConstants kBillableHour]])?@"1":@"0";
            recordDetailVC.record = tempRecordForRecordDetail;
            [self.previousViewController.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    //Reset placeHolder text
    self.commentTextView.text = placeHolderForTextView;

}


@end
