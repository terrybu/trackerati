//
//  CustonLabel.h
//  trackerati-ios
//
//  Created by Ethan on 1/9/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface CustomLabel : UILabel

@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;

@end
