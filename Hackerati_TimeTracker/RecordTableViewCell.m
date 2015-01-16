//
//  RecordTableViewCell.m
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "RecordTableViewCell.h"

@interface RecordTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
- (IBAction)clickedDetailButton:(id)sender;

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
    [super prepareForReuse];
    self.clientNameLabel.text = nil;
    self.projectNameLabel.text = nil;
    self.hourLabel.text = nil;
    self.indexPath = nil;
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


- (IBAction)clickedDetailButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickDetailButton:)]) {
        [self.delegate didClickDetailButton:self.indexPath];
    }
}
@end
