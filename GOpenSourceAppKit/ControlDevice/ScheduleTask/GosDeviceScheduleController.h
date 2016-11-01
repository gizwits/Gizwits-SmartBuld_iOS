//
//  GosDeviceScheduleController.h
//  SmartSocket
//
//  Created by danly on 16/7/29.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiDevice.h>
#import "GosDeviceScheduleTask.h"

// 定时预约界面
@interface GosDeviceScheduleController : UIViewController

- (instancetype)initWithDevice:(GizWifiDevice *)device;

@end
