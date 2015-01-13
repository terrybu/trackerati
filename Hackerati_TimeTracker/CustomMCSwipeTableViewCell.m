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

- (void)prepareForReuse{
    [super prepareForReuse];
    self.client = nil;
    self.project = nil;
    self.textLabel.text = nil;
}

@end
