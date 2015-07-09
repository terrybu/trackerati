//
//  PinButtonCell.h
//  Trackerati
//
//  Created by Terry Bu on 7/9/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) UIView *overlay;


@end

