//
//  RecordTableViewCell.h
//  trackerati-ios
//
//  Created by Ethan on 1/6/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RecordTableViewCellProtocol <NSObject>

-(void)didClickDetailButton:(NSIndexPath*)indexPath;

@end

@interface RecordTableViewCell : UITableViewCell

@property (weak, nonatomic) id <RecordTableViewCellProtocol> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

-(void)setclientNameLabelString:(NSString*)name;

-(void)setprojectNameLabelString:(NSString*)name;

-(void)sethourLabelString:(NSString*)name;

@end
