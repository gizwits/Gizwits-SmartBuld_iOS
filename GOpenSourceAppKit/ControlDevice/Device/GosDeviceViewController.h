//
//  GosDeviceViewController.h
//  SmartLight
//
//  Created by danly on 16/7/26.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GizWifiSDK/GizWifiDevice.h>
@interface GosDeviceViewController : UIViewController

+ (instancetype)deviceControllerWithDevice:(GizWifiDevice *)device withDeviceListController:(UIViewController *)deviceListController;

@end
