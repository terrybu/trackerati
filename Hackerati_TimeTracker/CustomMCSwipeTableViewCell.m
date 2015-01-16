//
//  CustomMCSwipeTableViewCell.m
//  trackerati-ios
//
//  Created by Ethan on 1/9/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "CustomMCSwipeTableViewCell.h"

@implementation CustomMCSwipeTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.customButton = [CustomButton buttonWithType:UIButtonTypeContactAdd];
        [self.customButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = self.customButton;
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.client = nil;
    self.project = nil;
    self.textLabel.text = nil;
    self.customButton.indexPath = nil;
}

- (void)buttonClick:(id)sender{
    CustomButton *button = (CustomButton*) sender;
    if ([self.delegate respondsToSelector:@selector(didPressCustomButton:)]) {
        [self.delegate didPressCustomButton:button.indexPath];
    }
}

@end
