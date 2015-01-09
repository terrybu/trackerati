//
//  RecordDetailViewController.m
//  trackerati-ios
//
//  Created by Ethan on 1/9/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "RecordDetailViewController.h"

@interface RecordDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *clientLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end

@implementation RecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.viewTitle;
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f/1.0f];
    
    self.clientLabel.text = [self.record objectForKey:@"client"];
    self.projectLabel.text = [self.record objectForKey:@"project"];
    self.hourLabel.text = [[self.record objectForKey:@"hour"] isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",[self.record objectForKey:@"hour"]]:[self.record objectForKey:@"hour"];
    if ([self.record objectForKey:@"comment"]) {
        self.commentLabel.text = [self.record objectForKey:@"comment"];
    } else{
        self.commentLabel.text = @"<NONE>";
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

@end
