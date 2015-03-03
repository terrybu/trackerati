//
//  RecordDetailViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/9/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "RecordDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Firebase/Firebase.h>
#import "HConstants.h"
#import "RecordFormViewController.h"
#import "DataParseManager.h"
#import <KVOController/FBKVOController.h>

@interface RecordDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *clientLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deletButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (strong, nonatomic) Firebase *fireBase;
@property (strong, nonatomic) FBKVOController *fbKVOController;

@property (nonatomic, strong) NSDateFormatter * formatter;

- (IBAction)editButtonAction:(id)sender;
- (IBAction)deleteButtonAction:(id)sender;

@end

@implementation RecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f/1.0f];
    
    self.editButton.layer.cornerRadius = 5.0f;
    self.editButton.clipsToBounds = YES;
    [self.editButton.layer setBorderWidth:0.5f];
    [self.editButton.layer setBorderColor:[UIColor grayColor].CGColor];
    
    self.deletButton.layer.cornerRadius = 5.0f;
    self.deletButton.clipsToBounds = YES;
    [self.deletButton.layer setBorderWidth:0.5f];
    [self.deletButton.layer setBorderColor:[UIColor grayColor].CGColor];
    
    self.commentLabel.layer.cornerRadius = 5.0f;
    self.commentLabel.clipsToBounds = YES;
    [self.commentLabel.layer setBorderWidth:0.5f];
    [self.commentLabel.layer setBorderColor:[UIColor grayColor].CGColor];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MM/dd/yyyy"];
    
    self.fbKVOController = [[FBKVOController alloc]initWithObserver:self];
    __weak typeof(self) weakSelf = self;
    [self.fbKVOController observe:self keyPath:@"record" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change){
        [weakSelf setElements];
    }];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setElements];

    
    //Disabling logic for preventing user from editing/deleting records more than 7 days old
    //We scrapped the need to do this prevention so commenting it out for now
//    if (self.record.dateOfTheService) {
//        NSString *dateString = self.record.dateOfTheService;
//        NSDate *dateFromString = [self.formatter dateFromString:dateString];
//        int addDaysCount = 8;
//        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//        [dateComponents setDay:addDaysCount];
//        NSDate *cutOffDate = [[NSCalendar currentCalendar]
//                           dateByAddingComponents:dateComponents
//                           toDate:dateFromString options:0];
//        if ([cutOffDate compare:[NSDate date]] == NSOrderedAscending) {
//            self.deletButton.enabled = NO;
//            self.editButton.enabled = NO;
//        } else {
//            self.deletButton.enabled = YES;
//            self.editButton.enabled = YES;
//        }
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setElements{
    self.title = self.record.dateOfTheService;
    self.clientLabel.text = self.record.clientName;
    if (self.record.statusOfUser && [self.record.statusOfUser isEqualToString:@"1"] ) {
        self.statusLabel.text = [HConstants kFullTimeEmployee];
    }
    else{
        self.statusLabel.text = [HConstants kPartTimeEmployee];
    }
    
    if (self.record.typeOfService && [self.record.typeOfService isEqualToString:@"1"] ) {
        self.typeLabel.text = [HConstants kBillableHour];
    }
    else{
        self.typeLabel.text = [HConstants kUnbillableHour];
    }
    
    self.projectLabel.text = self.record.projectName;
    self.hourLabel.text = [self.record.hourOfTheService isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",self.record.hourOfTheService]:self.record.hourOfTheService;
    if (self.record.commentOnService) {
        self.commentLabel.text = self.record.commentOnService;
    } else{
        self.commentLabel.text = nil;
    }
}

- (IBAction)editButtonAction:(id)sender {
    RecordFormViewController *formViewController = [[RecordFormViewController alloc]initWithNibName:@"RecordFormViewController" bundle:nil];
    formViewController.existingRecord = self.record;
    Client *tempClient = [[Client alloc]init];
    tempClient.clientName = self.clientLabel.text;
    Project *tempProject = [[Project alloc]init];
    tempProject.projectName = self.projectLabel.text;
    formViewController.client = tempClient;
    formViewController.project = tempProject;
    formViewController.previousViewController = self;
    [self.navigationController pushViewController:formViewController animated:YES];
}

- (IBAction)deleteButtonAction:(id)sender {
    [[[UIAlertView alloc]initWithTitle:@"Delete" message:@"Are you sure you want to delete this record?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"delete", nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"delete"]) {
        [self didFinishDeletingRecordFromFirebase:^{
            __weak typeof(self) weakSelf = self;
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

-(void)deleteRecord{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants kCurrentUser]];
    NSString *uniqueAddress = self.record.uniqueFireBaseIdentifier;
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records/%@",[HConstants kFireBaseURL],username,uniqueAddress]];
    [self.fireBase removeValue];
}

- (void)didFinishDeletingRecordFromFirebase:(dispatch_block_t)block
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf deleteRecord];
        NSMutableArray *records = [self.historyViewController.recordsHistoryDictionary objectForKey:[self.historyViewController.sortedDateKeys objectAtIndex:self.indexPath.section]];
        if (records) {
            [records removeObject:self.record];
            if (records.count == 0) {
                [self.historyViewController.sortedDateKeys removeObjectAtIndex:self.indexPath.section];
            }
        }
        // Call your block back on the main queue now that previous process finished
        dispatch_async(dispatch_get_main_queue(), block);
    });
}


@end
