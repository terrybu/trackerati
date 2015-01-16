//
//  CustomMCSwipeTableViewCell.h
//  trackerati-ios
//
//  Created by Ethan on 1/9/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//
//#import <Foundation/Foundation.h>

#import "MCSwipeTableViewCell.h"
#import "CustomButton.h"

@protocol CustomMCSwipeTableViewCellDelegate <MCSwipeTableViewCellDelegate>

- (void)didPressCustomButton:(NSIndexPath*)indexPath;

@end

@interface CustomMCSwipeTableViewCell : MCSwipeTableViewCell

@property (strong, nonatomic) NSString *client;
@property (strong, nonatomic) NSString *project;
@property (strong, nonatomic) CustomButton *customButton;
@property (weak, nonatomic) id <CustomMCSwipeTableViewCellDelegate> delegate;

@end
