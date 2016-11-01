//
//  GosDeviceScheduleCell.m
//  SmartSocket
//
//  Created by danly on 16/7/29.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceScheduleCell.h"

@interface GosDeviceScheduleCell ()

@property (weak, nonatomic) IBOutlet UILabel *onOffLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *scheduleSwitch;
@property (weak, nonatomic) IBOutlet UIView *todayView;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeOnceView;
@property (weak, nonatomic) IBOutlet UILabel *onceLabel;

@property (nonatomic, weak) UIButton *pressBtn;

@end

@implementation GosDeviceScheduleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame])
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"GosDeviceScheduleCell" owner:nil options:nil] lastObject];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    if (self.pressBtn== nil)
    {
        
        UIButton *pressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.75, frame.size.height)];
        [self.contentView addSubview: pressBtn];
        self.pressBtn = pressBtn;
        [self.pressBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecoginer:)]];
    }
}

- (void)tapGestureRecoginer:(UITapGestureRecognizer *)tapGestureRecoginer
{
    if ([self.delegate respondsToSelector:@selector(scheduleCellDidSelect:)])
    {
        [self.delegate scheduleCellDidSelect:self];
    }
}

- (IBAction)switchValueChange:(UISwitch *)sender
{
 
    if ([self.delegate respondsToSelector:@selector(scheduleCell:switchValueChange:)])
    {
        [self.delegate scheduleCell:self switchValueChange:sender];
    }
}


- (void)setIsStartScheduleTask:(BOOL)isStartScheduleTask
{
    _isStartScheduleTask = isStartScheduleTask;
    self.onOffLabel.text = _isStartScheduleTask ? NSLocalizedString(@"ON", nil) : NSLocalizedString(@"OFF", nil);
}

- (void)setTime:(NSString *)time
{
    _time = time;
    self.timeLabel.text = time;
}

- (void)setRemark:(NSString *)remark
{
    _remark = remark;
    
    if ([remark isEqualToString:@""] || remark == nil)
    {
        self.weekLabel.hidden = YES;
        self.todayView.hidden = YES;
        self.closeOnceView.hidden = NO;
        self.closeOnceView.text = NSLocalizedString(@"Once", nil);
    }
    else if ([remark isEqualToString:NSLocalizedString(@"Today", nil)] || [remark isEqualToString:NSLocalizedString(@"Tomorrow", nil)])
    {
        // 仅有一次
        self.todayLabel.text = remark;
        self.weekLabel.hidden = YES;
        self.todayView.hidden = NO;
        self.closeOnceView.hidden = YES;
        self.onceLabel.text = NSLocalizedString(@"Once", nil);
    }
    else
    {
        // 有重复
        self.weekLabel.text = remark;
        self.weekLabel.hidden = NO;
        self.todayView.hidden = YES;
        self.closeOnceView.hidden = YES;
        
    }
}



- (void)setIsStart:(BOOL)isStart
{
    _isStart = isStart;
    self.scheduleSwitch.on = isStart;
    
    [self setTextColorWithSwitchValue:isStart];
    
}

- (void)setTextColorWithSwitchValue:(BOOL)switchValue
{
    if (switchValue == YES)
    {
        [self setAllLabelTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]];
    }
    else
    {
        [self setAllLabelTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]];
    }
}

- (void)setAllLabelTextColor:(UIColor *)color
{
    self.weekLabel.textColor = color;
    self.todayLabel.textColor = color;
    self.onceLabel.textColor = color;
    self.onOffLabel.textColor = color;
    self.timeLabel.textColor = color;
    self.closeOnceView.textColor = color;
}


@end
