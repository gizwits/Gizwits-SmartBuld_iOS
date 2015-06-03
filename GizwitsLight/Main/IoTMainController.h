/**
 * IoTMainController.h
 *
 * Copyright (c) 2014~2015 Xtreme Programming Group, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

typedef enum
{
    // writable
    IoTDeviceWriteUpdateData = 0,           //更新数据
    IoTDeviceWriteOnOff,                    //开关
    IoTDeviceWriteMode,                     //选择调节模式
    IoTDeviceWriteC_Temperature,            //调节色温
    IoTDeviceWriteBrightness,               //亮度调节
    IoTDeviceWriteColor_R,                  //颜色调节_红
    IoTDeviceWriteColor_G,                  //颜色调节_绿
    IoTDeviceWriteColor_B,                  //颜色调节_蓝
    
}IoTDeviceDataPoint;

typedef enum
{
    IoTDeviceCommandWrite    = 1,//写
    IoTDeviceCommandRead     = 2,//读
    IoTDeviceCommandResponse = 3,//读响应
    IoTDeviceCommandNotify   = 4,//通知
}IoTDeviceCommand;

#define DATA_CMD                        @"cmd"                  //命令
#define DATA_ENTITY                     @"entity0"              //实体
#define DATA_ATTR_SWITCH                @"Switch"               //属性：开关
#define DATA_ATTR_C_TEMPERATURE         @"C_Temperature"        //色温调节
#define DATA_ATTR_BRIGHTNESS            @"Brightness"           //亮度调节
#define DATA_ATTR_MODE                  @"mode"                 //选择调节模式
#define DATA_ATTR_Color_R               @"Color_R"              //颜色调节_红
#define DATA_ATTR_Color_G               @"Color_G"              //颜色调节_绿
#define DATA_ATTR_Color_B               @"Color_B"              //颜色调节_蓝


@interface IoTMainController : UIViewController

//用于切换设备
@property (nonatomic, strong) XPGWifiDevice *device;

//写入数据接口
- (void)writeDataPoint:(IoTDeviceDataPoint)dataPoint value:(id)value;

- (id)initWithDevice:(XPGWifiDevice *)device;

//获取当前实例
+ (IoTMainController *)currentController;

@end
