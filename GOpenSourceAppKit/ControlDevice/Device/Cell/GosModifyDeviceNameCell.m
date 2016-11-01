//
//  GosModifyDeviceNameCell.m
//  SmartSocket
//
//  Created by danly on 16/7/5.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosModifyDeviceNameCell.h"

@interface GosModifyDeviceNameCell ()
@end

@implementation GosModifyDeviceNameCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self = [[[NSBundle mainBundle] loadNibNamed:@"GosModifyDeviceNameCell" owner:nil options:nil] lastObject];
        
        self.textField.textColor = [UIColor blackColor];
    }
    return self;
}



@end
