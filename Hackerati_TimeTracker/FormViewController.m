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

@interface FormViewController ()<THDatePickerDelegate>
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

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
- (IBAction)dateButtonAction:(id)sender;

@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.projectLabel.text = self.projectName;
    self.clientLabel.text = self.clientName;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    [self.dateButton setTitle:[formatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    self.dateString = [formatter stringFromDate:[NSDate date]];
    self.hourLabel.text = @"0";
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
    if(!self.datePicker)
        self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = self.curDate;
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:YES];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableHistorySelection:YES];
    [self.datePicker setDisableFutureSelection:NO];
    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColorSelected:[UIColor yellowColor]];
    
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        return (tmp % 5 == 0);
    }];
    //[self.datePicker slideUpInView:self.view withModalColor:[UIColor lightGrayColor]];
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(1.0),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    self.curDate = datePicker.date;
    //[self.datePicker slideDownAndOut];
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
    NSDictionary *history = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KSanitizedCurrentUserRecords]];
    if ([history objectForKey:self.dateString]) {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat: @"You already sent a record for %@. Do you still want to send this ?",self.dateString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
    } else{
        [self sendData];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Send"]) {
        [self sendData];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)sendData{
    self.fireBase = [FireBaseManager recordURLsharedFireBase];
    [[self.fireBase childByAutoId] setValue:@{@"client":self.clientName,@"date":self.dateString,@"hour":self.hourString,@"project":self.projectName}];
    [[LastSavedManager sharedManager] saveClient:self.clientName withProject:self.projectName andHour:self.hourString];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
