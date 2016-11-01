//
//  GosMoreController.h
//  SmartSocket
//
//  Created by danly on 16/7/28.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiDevice.h>

// 更多界面
@interface GosMoreController : UIViewController

- (instancetype)initWithDevice:(GizWifiDevice *)device;

@property (nonatomic, strong) UIViewController *deviceListViewController;

@end
