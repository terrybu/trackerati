//
//  TerryDrawerCell.m
//  JVFloatingDrawerPractice
//
//  Created by Terry Bu on 2/26/15.
//  Copyright (c) 2015 Terry Bu. All rights reserved.
//

#import "DrawerCell.h"

@implementation DrawerCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.6];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self highlightCell:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self highlightCell:highlighted];
}

- (void)highlightCell:(BOOL)currentSelected {
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    
    if(currentSelected) {
        tintColor = [UIColor whiteColor];
    }
    
    self.titleLabel.textColor = tintColor;
    self.iconImageView.tintColor = tintColor;
}

@end
