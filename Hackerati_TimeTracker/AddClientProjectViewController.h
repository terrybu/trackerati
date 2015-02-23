//
//  NewClientProjectViewController.h
//  trackerati-ios
//
//  Created by Terry Bu on 2/19/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddClientProjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic)  NSMutableArray *clientNames;
@property (strong, nonatomic) NSMutableSet *setOfCurrentUserProjectNames;

@end
