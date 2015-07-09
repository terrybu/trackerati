//
//  PinButtonCell.m
//  Trackerati
//
//  Created by Terry Bu on 7/9/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinButtonCell.h"

@implementation PinButtonCell

- (void)awakeFromNib
{
    // Initialization code
    self.overlay = [UIView new];
    self.overlay.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
    [self.title addSubview:self.overlay];
    //    self.imgView.layer.cornerRadius = 45/2;
    self.imageView.layer.masksToBounds = YES;
    //    self.title.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    //    self.title.layer.cornerRadius = 5.f;
    //    self.title.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.transform = CGAffineTransformMakeRotation(-M_PI);
}

@end
