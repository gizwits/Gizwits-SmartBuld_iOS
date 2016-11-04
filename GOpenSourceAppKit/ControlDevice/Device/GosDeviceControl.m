//
//  IoTDeviceControlTool.m
//  SmartLight
//
//  Created by danly on 16/7/27.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceControl.h"

@implementation GosDeviceControl

+ (instancetype)sharedInstance
{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone: zone];
    });
    return instance;
}

#pragma mark - readAndWrite Action
// 往设备里面写数据点值
- (void)writeDataPoint:(GosDeviceDataPoint)dataPoint value:(id)value
{
    NSDictionary *data = nil;
    switch (dataPoint) {
        case GosDeviceWritePowerSwitch:
            data = @{DATA_ATTR_POWER_SWITCH: value};
            break;
        case GosDeviceWriteBrightness:
            data = @{DATA_ATTR_BRIGHTNESS: value};
            break;
        case GosDeviceWriteColorRed:
            data = @{DATA_ATTR_COLOR_R: value};
            break;
        case GosDeviceWriteColorGreen:
            data = @{DATA_ATTR_COLOR_G: value};
            break;
        case GosDeviceWriteColorBlue:
            data = @{DATA_ATTR_COLOR_B: value};
            break;
        case GosDeviceWriteMode:
            data = @{DATA_ATTR_MODE: value};
            break;
        case GosDeviceWriteCountDownOffMin:
            data = @{DATA_ATTR_COUNTDOWN_OFF_MIN: value};
            break;
        case GosDeviceWriteCountDownSwitch:
            data = @{DATA_ATTR_COUNTDOWN_SWITCH: value};
            break;
        case GosDeviceWriteTemperatureRed:
            data = @{DATA_ATTR_TEMPERATURE_R: value};
            break;
        case GosDeviceWriteTemperatureGreen:
            data = @{DATA_ATTR_TEMPERATURE_B: value};
            break;
        case GosDeviceWriteTemperatureBlue:
            data = @{DATA_ATTR_TEMPERATURE_B: value};
            break;
        default:
            NSLog(@"Error: write invalid datapoint, skip.");
            return;
    }
    
    NSLog(@"Write data: %@", data);
    
    if (self.device.netStatus != GizDeviceControlled)
    {
        if ([self.delegate respondsToSelector:@selector(GosDeviceControl:deviceUncontrol:)])
        {
            [self.delegate GosDeviceControl:self deviceUncontrol:self.device];
        }
        
        return;
    }
    [self.device write:data withSN:0];
    
}

// 写入颜色值到设备端
- (void)writeColor:(int)colorR colorG:(int)colorG colorB:(int)colorB
{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (self.mode == GosDeviceModeColor)
    {
        [data setValue:@(colorR) forKey:DATA_ATTR_COLOR_R];
        [data setValue:@(colorG) forKey:DATA_ATTR_COLOR_G];
        [data setValue:@(colorB) forKey:DATA_ATTR_COLOR_B];
    }
    else
    {
        [data setValue:@(colorR) forKey:DATA_ATTR_TEMPERATURE_R];
        [data setValue:@(colorG) forKey:DATA_ATTR_TEMPERATURE_G];
        [data setValue:@(colorB) forKey:DATA_ATTR_TEMPERATURE_B];
    }
    
    
    if (self.device.netStatus != GizDeviceControlled)
    {
        if ([self.delegate respondsToSelector:@selector(GosDeviceControl:deviceUncontrol:)])
        {
            [self.delegate GosDeviceControl:self deviceUncontrol:self.device];
        }
        
        return;
    }
    [self.device write:data withSN:0];
}

// 从数据点集合中获取数据点的值
- (void)readDataPointsFromData:(NSDictionary *)data
{
    [self readDataPoint:GosDeviceWriteColorRed data:data];
    [self readDataPoint:GosDeviceWriteColorGreen data:data];
    [self readDataPoint:GosDeviceWriteColorBlue data:data];
    [self readDataPoint:GosDeviceWritePowerSwitch data:data];
    [self readDataPoint:GosDeviceWriteBrightness data:data];
    [self readDataPoint:GosDeviceWriteMode data:data];
    [self readDataPoint:GosDeviceWriteCountDownOffMin data:data];
    [self readDataPoint:GosDeviceWriteCountDownSwitch data:data];
    [self readDataPoint:GosDeviceWriteTemperatureRed data:data];
    [self readDataPoint:GosDeviceWriteTemperatureGreen data:data];
    [self readDataPoint:GosDeviceWriteTemperatureBlue data:data];
}

// 读设备中的数据点值
- (void)readDataPoint:(GosDeviceDataPoint)dataPoint data:(NSDictionary *)data
{
    if(![data isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Error: could not read data, error data format.");
        return;
    }
    
    switch (dataPoint) {
        case GosDeviceWritePowerSwitch:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_POWER_SWITCH];
            self.powerSwitch = [self prepareForUpdateInteger:dataPointStr value:self.powerSwitch];
            break;
        }
        case GosDeviceWriteBrightness:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_BRIGHTNESS];
            self.brightness = [self prepareForUpdateInteger:dataPointStr value:self.brightness];
            break;
        }
        case GosDeviceWriteColorRed:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_COLOR_R];
            self.colorRed = [self prepareForUpdateInteger:dataPointStr value:self.colorRed];
            break;
        }
        case GosDeviceWriteColorGreen:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_COLOR_G];
            self.colorGreen = [self prepareForUpdateInteger:dataPointStr value:self.colorGreen];
            break;
        }
        case GosDeviceWriteColorBlue:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_COLOR_B];
            self.colorBlue = [self prepareForUpdateInteger:dataPointStr value:self.colorBlue];
            break;
        }
        case GosDeviceWriteMode:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_MODE];
            self.mode = (int)[self prepareForUpdateInteger:dataPointStr value:self.mode];
            break;
        }
        case GosDeviceWriteCountDownOffMin:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_COUNTDOWN_OFF_MIN];
            self.countDownOffMin = [self prepareForUpdateInteger:dataPointStr value:self.countDownOffMin];
            break;
        }
        case GosDeviceWriteCountDownSwitch:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_COUNTDOWN_SWITCH];
            self.countDownSwitch = [self prepareForUpdateInteger:dataPointStr value:self.countDownSwitch];
            break;
        }
        case GosDeviceWriteTemperatureRed:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_TEMPERATURE_R];
            self.temperatureRed = [self prepareForUpdateInteger:dataPointStr value:self.countDownSwitch];
            break;
        }
        case GosDeviceWriteTemperatureBlue:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_TEMPERATURE_B];
            self.temperatureBlue = [self prepareForUpdateInteger:dataPointStr value:self.countDownSwitch];
            break;
        }
        case GosDeviceWriteTemperatureGreen:
        {
            NSString *dataPointStr = [data valueForKey:DATA_ATTR_TEMPERATURE_G];
            self.temperatureGreen = [self prepareForUpdateInteger:dataPointStr value:self.countDownSwitch];
            break;
        }
        default:
            NSLog(@"Error: read invalid datapoint, skip.");
            break;
    }
}


// 根据数据点的字符串值获取数值
- (NSInteger)prepareForUpdateInteger:(NSString *)str value:(NSInteger)value
{
    if([str isKindOfClass:[NSNumber class]] ||
       ([str isKindOfClass:[NSString class]] && str.length > 0))
    {
        NSInteger newValue = [str integerValue];
        if(newValue != value)
        {
            value = newValue;
        }
    }
    return value;
}

- (void)initDevice
{
    // 重新设置设备
    self.powerSwitch = NO;
    self.brightness = 50;
    self.colorRed = 255;
    self.colorBlue = 255;
    self.colorGreen = 255;
    self.temperatureBlue = 227;
    self.temperatureGreen = 141;
    self.temperatureBlue = 11;
    self.mode = GosDeviceModeColor;
    self.countDownOffMin = 0;
    self.countDownSwitch = NO;
}

- (void)postDataUpdateNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GosDeviceControlDataValueUpdateNotification object:nil];
}


- (void)setDevice:(GizWifiDevice *)device
{
    if (device != _device || _device == nil)
    {
        [self initDevice];
        
    }
    _device = device;
}


@end
