//
//  GosModifyDeviceNameController.h
//  SmartSocket
//
//  Created by danly on 16/7/28.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiDevice.h>

// 修改设备名称界面
@interface GosModifyDeviceNameController : UIViewController

- (instancetype)initWithDevice:(GizWifiDevice *)device;

@property (nonatomic, strong) UIViewController *deviceListViewController;

@end
