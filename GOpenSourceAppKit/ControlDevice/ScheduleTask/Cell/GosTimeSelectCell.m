//
//  GosTimeSelectCell.m
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosTimeSelectCell.h"

@interface GosTimeSelectCell ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, assign) GosTimeSelectType type;

@end

@implementation GosTimeSelectCell

- (instancetype)initWithTimerScheduleType:(GosTimeSelectType)type
{
    if (self = [super init])
    {
        self.type = type;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"GosTimeSelectCell" owner:nil options:nil] lastObject];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.type)
    {
        case GosTimeSelectTypeDelay:
            return 2;
        case GosTimeSelectTypeSchedule:
            return 4;
        default:
            return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.type == GosTimeSelectTypeSchedule)
    {
        switch (component)
        {
            case 0:
                return 24;
            case 1:
                return 1;
            case 2:
                return 60;
            case 3:
                return 1;
            default:
                return 0;
        }
    }
    else if(self.type == GosTimeSelectTypeDelay)
    {
        switch (component)
        {
            case 0:
                return 60;
            case 1:
                return 1;
        }
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.type == GosTimeSelectTypeSchedule)
    {
        switch (component)
        {
            case 0:
            case 2:
                return [NSString stringWithFormat:@"%02li", (long)row];
            case 1:
                return NSLocalizedString(@"H", nil);
            case 3:
                return NSLocalizedString(@"M", nil);
                
            default:
                break;
        }
        return [NSString stringWithFormat:@"%02li", (long)row];
    }
    else if(self.type == GosTimeSelectTypeDelay)
    {
        switch (component)
        {
            case 0:
                return [NSString stringWithFormat:@"%li", (long)row + 1];
            case 1:
                return NSLocalizedString(@"M", nil);
            default:
                return nil;
        }
    }
 
    return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (self.type)
    {
        case GosTimeSelectTypeDelay:
            return 50;
        case GosTimeSelectTypeSchedule:
            return 40;
        default:
            return 0;
    }
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger minutes = 0;
    
    if (self.type == GosTimeSelectTypeSchedule)
    {
        if (component == 0)
        {
            minutes = row * 60 + [pickerView selectedRowInComponent:1];
        }
        if (component == 2)
        {
            minutes = [pickerView selectedRowInComponent:0] * 60 + row;
        }
        
    }
    else if(self.type == GosTimeSelectTypeDelay)
    {
        if (component == 0)
        {
            minutes = row + 1;
        }
    }
    if ([self.delegate respondsToSelector:@selector(timerScheduleCell:didSelectedMinutes:)])
    {
        [self.delegate timerScheduleCell:self didSelectedMinutes:minutes];
    }
   
}

- (void)setMinutes:(NSInteger)minutes
{
    _minutes = minutes;
    
    if (self.type == GosTimeSelectTypeSchedule)
    {
        NSInteger hour = minutes / 60;
        NSInteger minute = minutes % 60;
        
        [self.pickerView selectRow:hour inComponent:0 animated:YES];
        [self.pickerView selectRow:minute inComponent:2 animated:YES];
    }
    else if(self.type == GosTimeSelectTypeDelay)
    {
        
        NSInteger selectRow = (minutes == 0) ? 0 : (minutes - 1);
        NSLog(@"%zd",selectRow);
        [self.pickerView selectRow:selectRow inComponent:0 animated:YES];
    }
}


@end
