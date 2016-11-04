//
//  GosDeviceScheduleEditController.h
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceScheduleTask.h"

typedef enum
{
    GosSubscribeStatusAdd = 0,   //添加新的预约
    GosSubscribeStatusUpdate = 1 //更新预约
}GosSubscribeStatus;

// 预约界面
@interface GosDeviceScheduleEditController : UIViewController

- (instancetype)initWithDevice:(GizWifiDevice *)device subscribeStatus:(GosSubscribeStatus)status withData:(GosDeviceScheduleTask *)data;

@end
