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

@interface FormViewController ()<THDatePickerDelegate,UITextViewDelegate>
@property (strong, nonatomic) THDatePickerViewController *datePicker;
@property (nonatomic, retain) NSDate * curDate;
@property (nonatomic, retain) NSDateFormatter * formatter;
@property (weak, nonatomic) IBOutlet UILabel *clientLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (nonatomic,copy) NSString *hourString;
@property (nonatomic,copy) NSString *dateString;
@property (strong, nonatomic) Firebase *fireBase;
- (IBAction)hourStepperControl:(id)sender;
- (IBAction)sendAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
- (IBAction)dateButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *hourStepper;

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
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.detailContainerView addGestureRecognizer:tap];
    
    if (self.isNewRecord) {
        self.title = @"New Record";
    } else {
        self.title = @"Edit Record";
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.isNewRecord) {
        self.projectLabel.text = self.projectName;
        self.clientLabel.text = self.clientName;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        [self.dateButton setTitle:[formatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
        self.dateString = [formatter stringFromDate:[NSDate date]];
        self.hourLabel.text = @"0.0";
        self.hourString = @"0.0";
        self.hourStepper.value = 0.0;
    } else{
        self.projectLabel.text = [self.existingRecord objectForKey:@"project"];
        self.clientLabel.text = [self.existingRecord objectForKey:@"client"];
        [self.dateButton setTitle:[self.existingRecord objectForKey:@"date"] forState:UIControlStateNormal];
        self.dateString = [self.existingRecord objectForKey:@"date"];
        self.hourLabel.text = [self.existingRecord objectForKey:@"hour"];
        self.hourString = [self.existingRecord objectForKey:@"hour"];
        self.hourStepper.value = [[NSString stringWithFormat:@"%.1f",[(NSString*)[self.existingRecord objectForKey:@"hour"] floatValue]] floatValue];
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


- (IBAction)dateButtonAction:(id)sender {
    if (self.isNewRecord) {
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    self.dateString = [formatter stringFromDate:self.curDate];
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    self.dateString = [formatter stringFromDate:selectedDate];
    [self.dateButton setTitle:[formatter stringFromDate:selectedDate] forState:UIControlStateNormal];
}
- (IBAction)hourStepperControl:(id)sender {
    UIStepper *steperControl = (UIStepper*)sender;
    self.hourLabel.text = [NSString stringWithFormat:@"%.1f",[steperControl value]];
    self.hourString = [NSString stringWithFormat:@"%.1f",[steperControl value]];
}

- (IBAction)sendAction:(id)sender {
    if (self.isNewRecord) {
        NSDictionary *history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
        if ([history objectForKey:self.dateString]) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this ?",self.dateString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
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

    [self.mainScrollView setContentOffset:CGPointMake(0, 140) animated:YES];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    BOOL reachedLimit = true;
    
    if ([[textView text] length] - range.length + text.length > 500)
        reachedLimit = false;
    return reachedLimit;
}

-(void)tapAction{
    [self.view endEditing:YES];
    [self.mainScrollView setContentOffset:CGPointMake(0, -64) animated:YES];
}

-(void)sendData{
    
    if ([self.hourString isEqualToString:@"0.0"]) {
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"You can not submit 0 hour" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
    }else{
        if (self.isNewRecord) {
            self.fireBase = [FireBaseManager recordURLsharedFireBase];
            if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
                [[self.fireBase childByAutoId] setValue:@{@"client":self.clientName,@"date":self.dateString,@"hour":self.hourString,@"project":self.projectName,@"comment":self.commentTextView.text}];
                [[LastSavedManager sharedManager] saveClient:self.clientName withProject:self.projectName withHour:self.hourString andComment:self.commentTextView.text];
            } else{
                [[self.fireBase childByAutoId] setValue:@{@"client":self.clientName,@"date":self.dateString,@"hour":self.hourString,@"project":self.projectName}];
                [[LastSavedManager sharedManager] saveClient:self.clientName withProject:self.projectName andHour:self.hourString];
            }
        } else{
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
            NSString *uniqueAddress = (NSString*)[self.existingRecord objectForKey:@"key"];
            self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records/%@",[HConstants kFireBaseURL],username,uniqueAddress]];
            if (self.commentTextView.text && ([self.commentTextView.text length] > 0)) {
                [self.fireBase updateChildValues:@{@"client":self.clientName,@"date":self.dateString,@"hour":self.hourString,@"project":self.projectName,@"comment":self.commentTextView.text}];
                [[LastSavedManager sharedManager] saveClient:self.clientName withProject:self.projectName withHour:self.hourString andComment:self.commentTextView.text];
            } else{
                [self.fireBase updateChildValues:@{@"client":self.clientName,@"date":self.dateString,@"hour":self.hourString,@"project":self.projectName}];
                [[LastSavedManager sharedManager] saveClient:self.clientName withProject:self.projectName andHour:self.hourString];
            }
    
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
@end
