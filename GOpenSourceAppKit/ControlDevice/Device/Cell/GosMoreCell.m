//
//  GosMoreCell.m
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosMoreCell.h"

@interface GosMoreCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@end

@implementation GosMoreCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"GosMoreCell" owner:nil options:nil] lastObject];
    }
    return self;
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

- (void)setDeviceName:(NSString *)deviceName
{
    _deviceName = deviceName;
    self.deviceNameLabel.text = deviceName;
    self.deviceNameLabel.textColor = [UIColor darkGrayColor];
    self.deviceNameLabel.font = [UIFont systemFontOfSize:16];
}


@end
