//
//  NewClientProjectViewController.h
//  trackerati-ios
//
//  Created by Terry Bu on 2/19/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddClientProjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic)  NSMutableArray *clientNames;

- (IBAction)confirmButtonPressed:(id)sender;

@end
