//
//  GosDelayCell.m
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDelayCell.h"

@interface GosDelayCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UISwitch *schedullSwitch;


@end

@implementation GosDelayCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"GosDelayCell" owner:nil options:nil] lastObject];
    }
    return self;
}


- (IBAction)switchChange:(UISwitch *)sender
{
    
    if ([self.delegate respondsToSelector:@selector(schedullCloseCell:switchValueChange:)])
    {
        [self.delegate schedullCloseCell:self switchValueChange:self.schedullSwitch];
    }
    self.isOn = sender.on;
}

#pragma mark - properity
- (void)setIconName:(NSString *)iconName
{
    _iconName = iconName;
    self.iconView.image = [UIImage imageNamed:iconName];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTime:(NSString *)time
{
    _time = time;
    self.timeLabel.text = time;
}

- (void)setIsOn:(BOOL)isOn
{
    _isOn = isOn;
    self.schedullSwitch.on = isOn;
    self.timeLabel.hidden = !isOn;
}


@end
