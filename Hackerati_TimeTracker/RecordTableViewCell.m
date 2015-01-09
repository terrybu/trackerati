//
//  RecordTableViewCell.m
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "RecordTableViewCell.h"

@interface RecordTableViewCell ()
@property (strong, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *hourLabel;

@end

@implementation RecordTableViewCell

- (void)awakeFromNib {
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse{
    self.clientNameLabel.text = nil;
    self.projectNameLabel.text = nil;

    self.hourLabel.text = nil;
}

-(void)setclientNameLabelString:(NSString*)name{
    self.clientNameLabel.text = name;
}

-(void)setprojectNameLabelString:(NSString*)name{
    self.projectNameLabel.text = name;
}

-(void)sethourLabelString:(NSString*)name{
    self.hourLabel.text = name;
}


@end
