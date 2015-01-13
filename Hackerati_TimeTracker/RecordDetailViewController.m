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
#import "DataParser.h"
#import "FormViewController.h"
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
    
    self.fbKVOController = [[FBKVOController alloc]initWithObserver:self];
    __weak typeof(self) weakSelf = self;
    [self.fbKVOController observe:self keyPath:@"record" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change){
        [weakSelf setElements];
    }];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setElements];
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

-(void)setElements{
    self.title = [self.record objectForKey:@"date"];
    self.clientLabel.text = [self.record objectForKey:@"client"];
    if ([self.record objectForKey:@"status"] && [[self.record objectForKey:@"status"]isEqualToString:@"1"] ) {
        self.statusLabel.text = @"Full-Time Employee";
    } else{
        self.statusLabel.text = @"Part-Time Employee";
    }
    if ([self.record objectForKey:@"type"] && [[self.record objectForKey:@"type"]isEqualToString:@"1"] ) {
        self.typeLabel.text = @"Billable Hour";
    }else{
        self.typeLabel.text = @"Unbillable Hour";
    }
    self.projectLabel.text = [self.record objectForKey:@"project"];
    self.hourLabel.text = [[self.record objectForKey:@"hour"] isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",[self.record objectForKey:@"hour"]]:[self.record objectForKey:@"hour"];
    if ([self.record objectForKey:@"comment"]) {
        self.commentLabel.text = [self.record objectForKey:@"comment"];
    } else{
        self.commentLabel.text = nil;
    }
}

- (IBAction)editButtonAction:(id)sender {
    FormViewController *formViewController = [[FormViewController alloc]initWithNibName:@"FormViewController" bundle:nil];
    formViewController.existingRecord = self.record;
    formViewController.previousViewController = self;
    [self.navigationController pushViewController:formViewController animated:YES];
}

- (IBAction)deleteButtonAction:(id)sender {
    [[[UIAlertView alloc]initWithTitle:@"Delete" message:@"Are you sure you want to delete this record ?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"delete", nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"delete"]) {
        [self deleteRecord];
        [[DataParser sharedManager] getUserRecords];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)deleteRecord{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:[HConstants KCurrentUser]];
    NSString *uniqueAddress = (NSString*)[self.record objectForKey:@"key"];
    self.fireBase = [[Firebase alloc]initWithUrl:[NSString stringWithFormat:@"%@/Users/%@/records/%@",[HConstants kFireBaseURL],username,uniqueAddress]];
    [self.fireBase removeValue];
    
}
@end
