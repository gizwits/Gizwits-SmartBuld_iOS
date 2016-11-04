//
//  IoTDeviceControlTool.h
//  SmartLight
//
//  Created by danly on 16/7/27.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

// 数据点数据更新的通知
#define GosDeviceControlDataValueUpdateNotification @"GosDeviceControlDataValueUpdateNotification"

// 数据点标识符
#define DATA_ATTR_POWER_SWITCH      @"Power_Switch"            // 灯的开关
#define DATA_ATTR_BRIGHTNESS        @"Brightness"              // 亮度调节
#define DATA_ATTR_COLOR_R   @"Color_R"                         // 红色值
#define DATA_ATTR_COLOR_G   @"Color_G"                         // 绿色值
#define DATA_ATTR_COLOR_B   @"Color_B"                         // 蓝色值
#define DATA_ATTR_MODE    @"mode"                               // 模式调节 - 0：色彩调节  1：色温调节
#define DATA_ATTR_COUNTDOWN_OFF_MIN   @"CountDown_Off_min"      // 延时时长
#define DATA_ATTR_COUNTDOWN_SWITCH    @"CountDown_Switch"       // 延时开关
#define DATA_ATTR_TEMPERATURE_R    @"Temperature_R"
#define DATA_ATTR_TEMPERATURE_G    @"Temperature_G"
#define DATA_ATTR_TEMPERATURE_B    @"Temperature_B"

/**
 * 标志各个数据点的枚举值
 */
typedef enum
{
    // writable
    GosDeviceWritePowerSwitch = 0,
    GosDeviceWriteBrightness = 1,
    GosDeviceWriteColorRed = 2,
    GosDeviceWriteColorGreen = 3,
    GosDeviceWriteColorBlue = 4,
    GosDeviceWriteMode = 5,
    GosDeviceWriteCountDownOffMin = 6,
    GosDeviceWriteCountDownSwitch = 7,
    GosDeviceWriteTemperatureRed = 8,
    GosDeviceWriteTemperatureGreen = 9,
    GosDeviceWriteTemperatureBlue = 10,
    
}GosDeviceDataPoint;

typedef enum
{
    GosDeviceModeColor,  // 色彩调节
    GosDeviceModeTemperature  //色温调节
}GosDeviceModeType;  // 调节模式枚举

/**
 *  设备控制代理类
 */
@class GosDeviceControl;
@protocol GosDeviceControlDelegate <NSObject>

// 当设备不可控时会调用
- (void)GosDeviceControl:(GosDeviceControl *)deviceControl deviceUncontrol:(GizWifiDevice *)device;

@end

@interface GosDeviceControl : NSObject

/**
 *  灯的开关
 */
@property (nonatomic, assign) BOOL powerSwitch;

/**
 *  亮度值   1-100
 */
@property (nonatomic, assign) NSInteger brightness;

/**
 *  红色值
 */
@property (nonatomic, assign) NSInteger colorRed;

/**
 *  绿色值
 */
@property (nonatomic, assign) NSInteger colorGreen;

/**
 *  蓝色值
 */
@property (nonatomic, assign) NSInteger colorBlue;

/**
 *  色温红色值
 */
@property (nonatomic, assign) NSInteger temperatureRed;

/**
 *  色温绿色值
 */
@property (nonatomic, assign) NSInteger temperatureGreen;

/**
 *  色温蓝色值
 */
@property (nonatomic, assign) NSInteger temperatureBlue;

/**
 *  设备调节模式
 */
@property (nonatomic, assign) GosDeviceModeType mode;


/**
 *  延时时长
 */
@property (nonatomic, assign) NSInteger countDownOffMin;

/**
 *  延时开关
 */
@property (nonatomic, assign) BOOL countDownSwitch;

/**
 *  代理
 */
@property (nonatomic, weak) id<GosDeviceControlDelegate> delegate;
@property (nonatomic, strong) GizWifiDevice *device;

+ (instancetype)sharedInstance;

/**
 *  写数据点的值到设备
 *
 *  @param dataPoint 标识数据点的枚举值
 *  @param value     数据点值
 */
- (void)writeDataPoint:(GosDeviceDataPoint)dataPoint value:(id)value;


/**
 *  写入颜色值到设备端
 *
 *  @param colorRGB RGB三个颜色值构成的数组
 */
- (void)writeColor:(int)colorR colorG:(int)colorG colorB:(int)colorB;

/**
 *  从数据点集合中获取数据点的值
 *
 *  @param data 数据点集合
 */
- (void)readDataPointsFromData:(NSDictionary *)data;


/**
 *  初始化设备  ，即将设备的值都设为默认值
 */
- (void)initDevice;

/**
 *  发出数据点数据已经更新的通知
 */
- (void)postDataUpdateNotification;


@end
