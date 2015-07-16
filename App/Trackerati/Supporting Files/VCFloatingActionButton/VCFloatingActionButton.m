//
//  VCFloatingActionButton.m
//  starttrial
//
//  Created by Giridhar on 25/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import "VCFloatingActionButton.h"
#import "FloatTableViewCell.h"
#import "PinButtonCell.h"
#import "Trackerati-Swift.h"
#import <QuartzCore/QuartzCore.h>

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

CGFloat animationTime = 0.55;
CGFloat rowHeight = 60.f;
NSInteger noOfRows = 0;
NSInteger tappedRow;
CGFloat previousOffset;
CGFloat buttonToScreenHeight;



@implementation VCFloatingActionButton {
    int countOfAlreadyPostedFloatingDefaults;
}

@synthesize windowView;
//@synthesize hideWhileScrolling;
@synthesize delegate;

@synthesize bgScroller;

-(id)initWithFrame:(CGRect)frame normalImage:(UIImage*)passiveImage andPressedImage:(UIImage*)activeImage withScrollview:(UIScrollView*)scrView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        windowView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _mainWindow = [UIApplication sharedApplication].keyWindow;
        _buttonView = [[UIView alloc]initWithFrame:frame];
        _buttonView.backgroundColor = [UIColor clearColor];
        _buttonView.userInteractionEnabled = YES;
        
        buttonToScreenHeight = SCREEN_HEIGHT - CGRectGetMaxY(self.frame);
        
        _menuTable = [[UITableView alloc]initWithFrame:CGRectMake(12, 0, 0.99 * SCREEN_WIDTH,SCREEN_HEIGHT - (SCREEN_HEIGHT - CGRectGetMaxY(self.frame)) )];
        //originally this was Screenwidth/18 and 0.95 * screen width for width but left side of label was getting truncated
        
        _menuTable.scrollEnabled = NO;
        
        
        _menuTable.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, CGRectGetHeight(frame))];

        _menuTable.delegate = self;
        _menuTable.dataSource = self;
        _menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTable.backgroundColor = [UIColor clearColor];

        _menuTable.transform = CGAffineTransformMakeRotation(-M_PI); //Rotate the table
        
        previousOffset = scrView.contentOffset.y;
        
        bgScroller = scrView;
        
        _pressedImage = activeImage;
        _normalImage = passiveImage;
        [self setupButton];
        
    }
    return self;
}


-(void)setHideWhileScrolling:(BOOL)hideWhileScrolling
{
    if (bgScroller!=nil)
    {
        _hideWhileScrolling = hideWhileScrolling;
        if (!hideWhileScrolling)
        {
            [bgScroller removeObserver:self forKeyPath:@"contentOffset"];
        }
        else
        {
            [bgScroller addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}



-(void) setupButton
{
    _isMenuVisible = false;
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:buttonTap];
    
    
    UITapGestureRecognizer *buttonTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    [_buttonView addGestureRecognizer:buttonTap3];
    
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *vsview = [[UIVisualEffectView alloc]initWithEffect:blur];
    
    
    _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    _bgView.alpha = 0;
    _bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *buttonTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    buttonTap2.cancelsTouchesInView = NO;
    vsview.frame = _bgView.bounds;
    _bgView = vsview;
    [_bgView addGestureRecognizer:buttonTap2];
    
    
    _normalImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _normalImageView.userInteractionEnabled = YES;
    _normalImageView.contentMode = UIViewContentModeScaleAspectFit;
    _normalImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _normalImageView.layer.shadowRadius = 5.f;
    _normalImageView.layer.shadowOffset = CGSizeMake(-10, -10);
    
    
    
    _pressedImageView  = [[UIImageView alloc]initWithFrame:self.bounds];
    _pressedImageView.contentMode = UIViewContentModeScaleAspectFit;
    _pressedImageView.userInteractionEnabled = YES;
    
    
    _normalImageView.image = _normalImage;
    _pressedImageView.image = _pressedImage;
    
    
    [_bgView addSubview:_menuTable];
    
    [_buttonView addSubview:_pressedImageView];
    [_buttonView addSubview:_normalImageView];
    [self addSubview:_normalImageView];
    
}

-(void)handleTap:(id)sender //Show Menu
{
    
    
    if (_isMenuVisible)
    {
        
        [self dismissMenu:nil];
    }
    else
    {
        [windowView addSubview:_bgView];
        [windowView addSubview:_buttonView];
        
        [_mainWindow addSubview:windowView];
        [self showMenu:nil];
    }
    _isMenuVisible  = !_isMenuVisible;
    
    
}




#pragma mark -- Animations
#pragma mark ---- button tap Animations

-(void) showMenu:(id)sender
{
    
    self.pressedImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.pressedImageView.alpha = 0.0; //0.3
    [UIView animateWithDuration:animationTime/2 animations:^
     {
         self.bgView.alpha = 1;
         
         
         self.normalImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.alpha = 0.0; //0.7
         
         
         self.pressedImageView.transform = CGAffineTransformIdentity;
         self.pressedImageView.alpha = 1;
         noOfRows = _labelArray.count;
         [_menuTable reloadData];
         
     }
                     completion:^(BOOL finished)
     {
     }];
    
}

-(void) dismissMenu:(id) sender

{
    [UIView animateWithDuration:animationTime/2 animations:^
     {
         self.bgView.alpha = 0;
         self.pressedImageView.alpha = 0.f;
         self.pressedImageView.transform = CGAffineTransformMakeRotation(-M_PI);
         self.normalImageView.transform = CGAffineTransformMakeRotation(0);
         self.normalImageView.alpha = 1.f;
     } completion:^(BOOL finished)
     {
         noOfRows = 0;
         [_bgView removeFromSuperview];
         [windowView removeFromSuperview];
         [_mainWindow removeFromSuperview];
         
     }];
}

#pragma mark ---- Scroll animations

-(void) showMenuDuringScroll:(BOOL) shouldShow
{
    if (_hideWhileScrolling)
    {
        
        if (!shouldShow)
        {
            [UIView animateWithDuration:animationTime animations:^
             {
                 self.transform = CGAffineTransformMakeTranslation(0, buttonToScreenHeight*6);
             } completion:nil];
        }
        else
        {
            [UIView animateWithDuration:animationTime/2 animations:^
             {
                 self.transform = CGAffineTransformIdentity;
             } completion:nil];
        }
        
    }
}


-(void) addRows
{
    NSMutableArray *ip = [[NSMutableArray alloc]init];
    for (int i = 0; i< noOfRows; i++)
    {
        [ip addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [_menuTable insertRowsAtIndexPaths:ip withRowAnimation:UITableViewRowAnimationFade];
}




#pragma mark -- Observer for scrolling
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        
//        NSLog(@"%f",bgScroller.contentOffset.y);
        
        CGFloat diff = previousOffset - bgScroller.contentOffset.y;
        
        if (ABS(diff) > 15)
        {
            if (bgScroller.contentOffset.y > 0)
            {
                [self showMenuDuringScroll:(previousOffset > bgScroller.contentOffset.y)];
                previousOffset = bgScroller.contentOffset.y;
            }
            else
            {
                [self showMenuDuringScroll:YES];
            }
            
            
        }
        
    }
}


#pragma mark -- Tableview methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return noOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(FloatTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
    //KeyFrame animation
    
    //    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    //    anim.fromValue = @((indexPath.row+1)*CGRectGetHeight(cell.imgView.frame)*-1);
    //    anim.toValue   = @(cell.frame.origin.y);
    //    anim.duration  = animationTime/2;
    //    anim.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    [cell.layer addAnimation:anim forKey:@"position.y"];
    
    
    
    
    double delay = (indexPath.row*indexPath.row) * 0.004;  //Quadratic time function for progressive delay
    
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0,-(indexPath.row+1)*CGRectGetHeight(cell.imgView.frame));
    cell.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    cell.alpha = 0.f;
    
    [UIView animateWithDuration:animationTime/2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         
         cell.transform = CGAffineTransformIdentity;
         cell.alpha = 1.f;
         
     } completion:^(BOOL finished)
     {
         
     }];
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *pinIdentifier = @"pinIdentifier";
    static NSString *floatingIdentifier = @"floatingIdentifier";
    
    FirebaseManager *firebaseManager = [FirebaseManager sharedManager];
    Record *record = [firebaseManager findRecordThatCorrespondsToFloatingCell:[_labelArray objectAtIndex:indexPath.row] indexPath: indexPath];
    NSString *imageString = [_imageArray objectAtIndex:indexPath.row];
    NSString *labelString = [_labelArray objectAtIndex:indexPath.row];

    if ([imageString isEqualToString:@"floatingPinCircle"]) {
        PinButtonCell *cell = [_menuTable dequeueReusableCellWithIdentifier:pinIdentifier];
        if (!cell)
        {
            [_menuTable registerNib:[UINib nibWithNibName:@"PinButtonCell" bundle:nil]forCellReuseIdentifier:pinIdentifier];
            cell = [_menuTable dequeueReusableCellWithIdentifier:pinIdentifier];
        }
        cell.imgView.image = [UIImage imageNamed:imageString];
        cell.title.text = labelString;
        return cell;
    }
    else {
        FloatTableViewCell *cell = [_menuTable dequeueReusableCellWithIdentifier:floatingIdentifier];
        if (!cell)
        {
            [_menuTable registerNib:[UINib nibWithNibName:@"FloatTableViewCell" bundle:nil]forCellReuseIdentifier:floatingIdentifier];
            cell = [_menuTable dequeueReusableCellWithIdentifier:floatingIdentifier];
        }
        cell.imgView.image = [UIImage imageNamed:imageString];
        cell.title.text = [NSString stringWithFormat:@"Quick-log %@", labelString];
        [cell.title setFont:[UIFont systemFontOfSize:16]];
        cell.hoursLabel.text = [NSString stringWithFormat:@"%@ hours", record.hours];
        
        //manually adding in hourslabel
//        UILabel *newHoursLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.size.width - 100, 40, 60, 10)];
//        newHoursLabel.text = [NSString stringWithFormat:@"%@ hours", record.hours];
//        [newHoursLabel setFont:[UIFont systemFontOfSize:12]];
//        newHoursLabel.textColor = [UIColor whiteColor];
//        [cell.contentView addSubview:newHoursLabel];
        
        //TRAC_66 (Grayout cell if selected already for today Logic)
        //now we take this record and see if that record has the same date as today --> which means it was posted already for today and don't need to be selected
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yyyy";
        NSString *todaysDate = [dateFormatter stringFromDate: [NSDate date]];
        
        //Custom UI for defaults that have already been posted
        if (record != nil && [record.date isEqualToString:todaysDate]) {
            cell.backgroundColor = [UIColor blackColor];
            [cell.layer setCornerRadius:30.0f];
            [cell.layer setMasksToBounds:YES];
            cell.title.textColor = [UIColor grayColor];
            cell.hoursLabel.textColor = [UIColor grayColor];

            cell.imgView.image = [UIImage imageNamed:@"floatingGrayEmptyCircle"];
            //        if (countOfAlreadyPostedFloatingDefaults > 0) {
            //this is to add a white divider between our cells so when floating defaults get repeated twice or more, their divisions look beter. Otherwise, the backgrounds of cells overlap and look ugly
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, 1)];
            lineView.backgroundColor = [UIColor whiteColor];
            lineView.autoresizingMask = 0x3f;
            [cell.contentView addSubview:lineView];
            //        }
            //        countOfAlreadyPostedFloatingDefaults++;
            cell.alreadyUsedThisFloatingDefaultForTodayFlag = true;
        }
        return cell;
    }

    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *imageString = [_imageArray objectAtIndex:indexPath.row];
    if ([imageString isEqualToString:@"floatingPinCircle"]) {
        PinButtonCell *cell = (PinButtonCell*) [tableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:animationTime/2 animations:^
         {
             cell.imgView.transform = CGAffineTransformMakeRotation(M_PI);
         }
                         completion:^(BOOL finished)
         {
             cell.imgView.transform = CGAffineTransformMakeRotation(M_PI * 2);
             [delegate didSelectMenuOptionAtIndex:indexPath.row];
         }];
    }
    else {
        FloatTableViewCell *cell = (FloatTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
        if (cell.alreadyUsedThisFloatingDefaultForTodayFlag) {
            return;
        }
        [UIView animateWithDuration:animationTime/2 animations:^
         {
             cell.imgView.transform = CGAffineTransformMakeRotation(M_PI);
         }
                         completion:^(BOOL finished)
         {
             cell.imgView.transform = CGAffineTransformMakeRotation(M_PI * 2);
             [delegate didSelectMenuOptionAtIndex:indexPath.row];
         }];
    }
}

@end
