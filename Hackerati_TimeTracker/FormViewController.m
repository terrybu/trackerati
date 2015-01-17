//
//  FormViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "FormViewController.h"
#import "THDatePickerViewController.h"
#import "FireBaseManager.h"
#import "HConstants.h"
#import "LastSavedManager.h"
#import <QuartzCore/QuartzCore.h>
#import "DataParser.h"
#import "IQDropDownTextField.h"


@interface FormViewController ()<THDatePickerDelegate,UITextViewDelegate,IQDropDownTextFieldDelegate>

@property (strong, nonatomic) THDatePickerViewController *datePicker;
@property (nonatomic, strong) NSDate * curDate;
@property (nonatomic, strong) NSDateFormatter * formatter;

@property (weak, nonatomic) IBOutlet UILabel *clientLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
- (IBAction)sendAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;
- (IBAction)typeButtonAction:(id)sender;
- (IBAction)statusButtonAction:(id)sender;
- (IBAction)dateButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *hourTextField;

@property (strong, nonatomic) Firebase *fireBase;
@property (nonatomic) BOOL isDatePickerShowing;

@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f/1.0f];
    self.detailContainerView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f/1.0f];
    
    self.commentTextView.layer.cornerRadius = 5.0f;
    self.commentTextView.clipsToBounds = YES;
    [self.commentTextView.layer setBorderWidth:0.5f];
    [self.commentTextView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.clipsToBounds = YES;
    [self.sendButton.layer setBorderWidth:0.5f];
    [self.sendButton.layer setBorderColor:[UIColor grayColor].CGColor];
    
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
    
    self.hourTextField.isOptionalDropDown = YES;
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
        [self.statusButton setTitle:@"Full-Time Employee" forState:UIControlStateNormal];
        [self.typeButton setTitle:@"Billable Hour" forState:UIControlStateNormal];
        
        NSDictionary *lastSavedRecord = [[LastSavedManager sharedManager]getRecordForClient:self.clientLabel.text withProject:self.self.projectLabel.text];
        if ([lastSavedRecord objectForKey:@"comment"]) {
            self.commentTextView.text = [lastSavedRecord objectForKey:@"comment"];
        } else{
            self.commentTextView.text = nil;
        }
        
    } else{
        self.projectLabel.text = [self.existingRecord objectForKey:@"project"];
        self.projectName = [self.existingRecord objectForKey:@"project"];
        self.clientLabel.text = [self.existingRecord objectForKey:@"client"];
        self.clientName = [self.existingRecord objectForKey:@"client"];
        [self.dateButton setTitle:[self.existingRecord objectForKey:@"date"] forState:UIControlStateNormal];
        self.hourTextField.text = [self.existingRecord objectForKey:@"hour"];
        if ([self.existingRecord objectForKey:@"status"] && [[self.existingRecord objectForKey:@"status"]isEqualToString:@"1"] ) {
            [self.statusButton setTitle:@"Full-Time Employee" forState:UIControlStateNormal];
        } else{
            [self.statusButton setTitle:@"Part-Time Employee" forState:UIControlStateNormal];
        }
        if ([self.existingRecord objectForKey:@"type"] && [[self.existingRecord objectForKey:@"type"]isEqualToString:@"1"] ) {
            [self.typeButton setTitle:@"Billable Hour" forState:UIControlStateNormal];
        }else{
            [self.typeButton setTitle:@"Unbillable Hour" forState:UIControlStateNormal];
        }
        if ([self.existingRecord objectForKey:@"comment"]) {
            self.commentTextView.text = [self.existingRecord objectForKey:@"comment"];
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
    if ([typeButton.titleLabel.text isEqualToString:@"Billable Hour"]){
        [typeButton setTitle:@"UnBillable Hour" forState:UIControlStateNormal];
    } else{
        [typeButton setTitle:@"Billable Hour" forState:UIControlStateNormal];
    }
    
}

- (IBAction)statusButtonAction:(id)sender {
    UIButton *statusButton = (UIButton*)sender;
    if ([statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"]){
        [statusButton setTitle:@"Part-Time Employee" forState:UIControlStateNormal];
    } else{
        [statusButton setTitle:@"Full-Time Employee" forState:UIControlStateNormal];
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

- (IBAction)sendAction:(id)sender {
    if (self.isNewRecord) {
        NSDictionary *history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
        if ([history objectForKey:self.dateButton.titleLabel.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this ?",self.dateButton.titleLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
        } else{
            [self sendData];
        }
    } else {
        [self sendData];
    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Send"]) {
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

-(void)sendData{
    
    if ([self.hourTextField.text isEqualToString:@"0.0"]) {
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"You can not submit 0 hour" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
    }else{
        if (self.isNewRecord) {
            self.fireBase = [FireBaseManager recordURLsharedFireBase];
            if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
                [[self.fireBase childByAutoId] setValue:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"comment":self.commentTextView.text,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
                [[LastSavedManager sharedManager] saveRecord:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0"),@"comment":self.commentTextView.text}];
            } else{
                [[self.fireBase childByAutoId] setValue:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
                [[LastSavedManager sharedManager] saveRecord:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
            }
        } else{
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
            NSString *uniqueAddress = (NSString*)[self.existingRecord objectForKey:@"key"];
            self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records/%@",[HConstants kFireBaseURL],username,uniqueAddress]];
            if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
                [self.fireBase updateChildValues:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"comment":self.commentTextView.text,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
                [[LastSavedManager sharedManager] saveRecord:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0"),@"comment":self.commentTextView.text}];
            } else{
                [self.fireBase updateChildValues:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
                [[LastSavedManager sharedManager] saveRecord:@{@"client":self.clientName,@"date":self.dateButton.titleLabel.text,@"hour":self.hourTextField.text,@"project":self.projectName,@"status":(([self.statusButton.titleLabel.text isEqualToString:@"Full-Time Employee"])?@"1":@"0"),@"type":(([self.typeButton.titleLabel.text isEqualToString:@"Billable Hour"])?@"1":@"0")}];
            }
    
        }
        [[DataParser sharedManager] getUserRecords];
        if (self.previousViewController) {
            [self.previousViewController.navigationController popViewControllerAnimated:YES];
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    
}
@end
