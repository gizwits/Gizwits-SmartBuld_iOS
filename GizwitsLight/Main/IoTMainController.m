/**
 * IoTMainController.m
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

#import "IoTMainController.h"
#import "IoTAlertView.h"
#import "IoTMainMenu.h"
#import <CoreLocation/CoreLocation.h>
#import "HSVColorPicker.h"

#define ALERT_TAG_SHUTDOWN          1

@interface IoTMainController ()<UIAlertViewDelegate,IoTAlertViewDelegate,CLLocationManagerDelegate, XPGWifiSDKDelegate, XPGWifiDeviceDelegate, HSVColorPickerDelegate>
{
    //提示框
    IoTAlertView *_alertView;
    
    //数据点的临时变量
    BOOL bSwitch;
    BOOL bColor;
    NSInteger iMode;
    NSInteger iC_Temperature;
    NSInteger iBrightness;
    NSInteger iColor_R;
    NSInteger iColor_G;
    NSInteger iColor_B;
    
}

@property (weak, nonatomic  ) IBOutlet UIView                    *subView;

//模式
@property (weak, nonatomic  ) IBOutlet UIButton                  *btnColor;
@property (weak, nonatomic  ) IBOutlet UIButton                  *btnC_Temperature;
//色温、色彩、开关按钮
@property (weak, nonatomic  ) IBOutlet UISlider                  *sliderC_Temperature;
@property (weak, nonatomic  ) IBOutlet UISlider                  *sliderLight;
@property (weak, nonatomic  ) IBOutlet UIButton                  *btnShutdown;
//色彩圆环
@property (weak, nonatomic  ) IBOutlet HSVColorPicker            *colorPicker;
//亮度、色温、色彩圆心
@property (weak, nonatomic  ) IBOutlet UIImageView               *imageLightSlider;
@property (weak, nonatomic  ) IBOutlet UIImageView               *imageC_TemSlider;
@property (weak, nonatomic  ) IBOutlet UIView                    *colorView;

@property (weak, nonatomic  ) IBOutlet UILabel                   *labelColor;
@property (weak, nonatomic  ) IBOutlet UILabel                   *labelC_Temperature;

@property (strong, nonatomic) SlideNavigationController *navCtrl;

@end

@implementation IoTMainController

- (id)initWithDevice:(XPGWifiDevice *)device
{
    self = [super init];
    if(self)
    {
        if(nil == device)
        {
            NSLog(@"warning: device can't be null.");
            return nil;
        }
        self.device = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"智能灯";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu)];
    
    self.colorPicker.delegate = self;
    self.colorPicker.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.sliderC_Temperature setMinimumTrackImage:[UIImage imageNamed:@"stripe_min"] forState:(UIControlStateNormal)];
    [self.sliderC_Temperature setMaximumTrackImage:[UIImage imageNamed:@"stripe_min"] forState:(UIControlStateNormal)];
    [self.sliderC_Temperature addTarget:self action:@selector(changeValue) forControlEvents:(UIControlEventTouchCancel)];
    self.sliderC_Temperature.continuous     = NO;
    
    [self.sliderLight setMinimumTrackImage:[UIImage imageNamed:@"stripe_min"] forState:(UIControlStateNormal)];
    [self.sliderLight setMaximumTrackImage:[UIImage imageNamed:@"stripe_min"] forState:(UIControlStateNormal)];
    self.sliderLight.continuous             = NO;
    
    self.colorView.layer.masksToBounds      = YES;
    self.colorView.layer.cornerRadius       = 15.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //设置委托
    self.device.delegate = self;
    [XPGWifiSDK sharedInstance].delegate = self;
    
    //设备已解除绑定，或者断开连接，退出
    if(![self.device isBind:[IoTProcessModel sharedModel].currentUid] || !self.device.isConnected)
    {
        [self onDisconnected];
        return;
    }
    
    //更新侧边菜单数据
    [((IoTMainMenu *)[SlideNavigationController sharedInstance].leftMenu).tableView reloadData];
    
    //在页面加载后，自动更新数据
    if(self.device.isOnline)
    {
        IoTAppDelegate.hud.labelText = @"正在更新数据...";
        [IoTAppDelegate.hud showAnimated:YES whileExecutingBlock:^{
            sleep(61);
        }];
        [self writeDataPoint:IoTDeviceWriteUpdateData value:nil];
    }
    self.subView.userInteractionEnabled = bSwitch;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initDevice];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers indexOfObject:self] > self.navigationController.viewControllers.count)
    {
        self.device.delegate = nil;
    }
    [XPGWifiSDK sharedInstance].delegate = nil;
    [_alertView hide:YES];

}

- (void)initDevice{
    //加载页面时
    
    bSwitch       = 0;
    iMode         = -1;
    
    [self selectMode:iMode sendToDevice:NO];
    
    self.btnShutdown.selected               = bSwitch;
    self.subView.userInteractionEnabled     = bSwitch;
    
    self.device.delegate = self;
}

- (void)setDevice:(XPGWifiDevice *)device
{
    _device.delegate = nil;
    _device = device;
    [self initDevice];
}

#pragma mark - SDK delegate
- (void)writeDataPoint:(IoTDeviceDataPoint)dataPoint value:(id)value{
    
    NSDictionary *data = nil;
    
    switch (dataPoint)
    {
        case IoTDeviceWriteUpdateData:
            data = @{DATA_CMD: @(IoTDeviceCommandRead)};
            break;
        case IoTDeviceWriteOnOff:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite),
                     DATA_ENTITY: @{DATA_ATTR_SWITCH: value}};
            break;
        case IoTDeviceWriteC_Temperature:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite),
                     DATA_ENTITY: @{DATA_ATTR_C_TEMPERATURE: value}};
            break;
        case IoTDeviceWriteBrightness:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite),
                     DATA_ENTITY: @{DATA_ATTR_BRIGHTNESS: value}};
            break;
        case IoTDeviceWriteMode:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite),
                     DATA_ENTITY: @{DATA_ATTR_MODE: value}};
            break;
        case IoTDeviceWriteColor_R:
            data = @{DATA_CMD: @(IoTDeviceCommandWrite),
                     DATA_ENTITY: @{DATA_ATTR_Color_R: value}};
            break;
        case IoTDeviceWriteColor_G:
            data = @{DATA_CMD:@(IoTDeviceCommandWrite),
                     DATA_ENTITY: @{DATA_ATTR_Color_G: value}};
            break;
        case IoTDeviceWriteColor_B:
            data = @{DATA_CMD:@(IoTDeviceCommandWrite),
                     DATA_ENTITY: @{DATA_ATTR_Color_B: value}};
            break;
            
        default:
            NSLog(@"Error: write invalid datapoint, skip.");
            return;
    }
    NSLog(@"Write data: %@", data);
    [self.device write:data];
}

- (id)readDataPoint:(IoTDeviceDataPoint)dataPoint data:(NSDictionary *)data
{
    if(![data isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Error: could not read data, error data format.");
        return nil;
    }
    
    NSNumber *nCommand = [data valueForKey:DATA_CMD];
    if(![nCommand isKindOfClass:[NSNumber class]])
    {
        NSLog(@"Error: could not read cmd, error cmd format.");
        return nil;
    }
    
    int nCmd = [nCommand intValue];
    if(nCmd != IoTDeviceCommandResponse && nCmd != IoTDeviceCommandNotify)
    {
        NSLog(@"Error: command is invalid, skip.");
        return nil;
    }
    
    NSDictionary *attributes = [data valueForKey:DATA_ENTITY];
    if(![attributes isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Error: could not read attributes, error attributes format.");
        return nil;
    }
    
    switch (dataPoint)
    {
        case IoTDeviceWriteOnOff:
            return [attributes valueForKey:DATA_ATTR_SWITCH];
        case IoTDeviceWriteBrightness:
            return [attributes valueForKey:DATA_ATTR_BRIGHTNESS];
        case IoTDeviceWriteMode:
            return [attributes valueForKey:DATA_ATTR_MODE];
        case IoTDeviceWriteC_Temperature:
            return [attributes valueForKey:DATA_ATTR_C_TEMPERATURE];
        case IoTDeviceWriteColor_R:
            return [attributes valueForKey:DATA_ATTR_Color_R];
        case IoTDeviceWriteColor_G:
            return [attributes valueForKey:DATA_ATTR_Color_G];
        case IoTDeviceWriteColor_B:
            return [attributes valueForKey:DATA_ATTR_Color_B];
            
        default:
            NSLog(@"Error: read invalid datapoint, skip.");
            break;
            
    }
    return nil;
}

- (CGFloat)prepareForUpdateFloat:(NSString *)str value:(CGFloat)value
{
    if([str isKindOfClass:[NSNumber class]] ||
       ([str isKindOfClass:[NSString class]] && str.length > 0))
    {
        CGFloat newValue = [str floatValue];
        if(newValue != value)
        {
            value = newValue;
        }
    }
    return value;
}

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

#pragma mark - Actions
- (void)onDisconnected {
    self.device.delegate = nil;
    
    //断线且页面在控制页面时才弹框
    UIViewController *currentController = self.navigationController.viewControllers.lastObject;
    
    if(!self.device.isConnected &&
       [currentController isKindOfClass:[IoTMainController class]])
    {
        [IoTAppDelegate.hud hide:YES];
        [[[IoTAlertView alloc] initWithMessage:@"连接已断开" delegate:nil titleOK:@"确定"] show:YES];
        [self onExitToDeviceList];
    }
}

//退出到列表
- (void)onExitToDeviceList{
    UIViewController *currentController = self.navigationController.viewControllers.lastObject;
    for(int i=(int)(self.navigationController.viewControllers.count-1); i>0; i--)
    {
        UIViewController *controller = self.navigationController.viewControllers[i];
        if(([controller isKindOfClass:[IoTDeviceList class]] && [currentController isKindOfClass:[IoTMainController class]]))
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

//开关灯
- (IBAction)onShutDown:(UIButton *)sender {
    sender.selected = bSwitch;
    if(bSwitch)
    {
        //关机
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定关灯？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = ALERT_TAG_SHUTDOWN;
        [alertView show];
    }
    else
    {
        //开机
        [self writeDataPoint:IoTDeviceWriteOnOff value:@1];
        [self writeDataPoint:IoTDeviceWriteUpdateData value:nil];
    }
}

// ============== 选择色温,色彩模式 ==============
- (IBAction)onColor:(id)sender {
    if(iMode != 0)
        [self selectMode:0 sendToDevice:YES];
    
}

- (IBAction)onC_Temperature:(id)sender {
    if (iMode != 1) {
        [self selectMode:1 sendToDevice:YES];
    }
    
}
// ============== 色温调节 ==============
- (IBAction)setC_TemoeratureSliderValu:(id)sender {
    
    if (iMode != 1) {
        [self selectMode:1 sendToDevice:YES];
    }
    
    UISlider * Slider = sender;
    
    float i;
    
    if (Slider.value < 0.5 )
    {
        i = 0;
    }
    else if (Slider.value >= 0.5 && Slider.value < 1.5 )
    {
        i = 1;
    }
    else
    {
        i = 2;
    }
    
    self.sliderC_Temperature.value = i;
    [self setChangeC_TemperatureSliderValue:self.sliderC_Temperature.value];
}

- (void)changeValue{
    
    NSInteger value;
    
    value = self.sliderC_Temperature.value;
    
    if (value < 0.5) {
        self.sliderC_Temperature.value = 0;
    }
    else if (value >= 0.5 && value < 1.5)
    {
        self.sliderC_Temperature.value = 1;
    }
    else if (value >= 1.5)
    {
        self.sliderC_Temperature.value =2;
    }
    [self setChangeC_TemperatureSliderValue:value];
}

// ============ 调节亮度 ============
- (IBAction)setLightSliderValue:(UISlider *)sender {
    self.sliderLight = sender;
    [self setChangeBrightnessSliderValue:sender.value];
}

//选在色温、色彩
- (void)setChangeC_TemperatureSliderValue:(NSInteger)change{
    
    self.sliderC_Temperature.value = change;
    [self writeDataPoint:IoTDeviceWriteC_Temperature value:@(self.sliderC_Temperature.value)];
}

//亮度
- (void)setChangeBrightnessSliderValue:(NSInteger)change{
    self.sliderLight.value = change;
    [self writeDataPoint:IoTDeviceWriteBrightness value:@(self.sliderLight.value)];
}

//模式
- (void)selectMode:(NSInteger)index sendToDevice:(BOOL)send
{
    if(nil == self.btnColor)
        return;
    
    NSArray *btnItems = @[self.btnColor, self.btnC_Temperature];
    
    //模式：色彩，色温，就只能选择其中的一种
    if(index >= -1 && index <= 1)
    {
        iMode = index;
        for(int i=0; i<(btnItems.count); i++)
        {
            BOOL bSelected = (index == i);
            ((UIButton *)btnItems[i]).selected = bSelected;
        }
        
        //发送数据
        if(send && index != -1)
            [self writeDataPoint:IoTDeviceWriteMode value:@(iMode)];
    }
}

- (void)updateViewWithColor: (UIColor *) color {
    
    if(iMode != 0)
        [self selectMode:0 sendToDevice:YES];
    
    [self.colorView setBackgroundColor:color];
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    [self writeDataPoint:IoTDeviceWriteColor_R value:@((int)(components[0] * 255))];
    [self writeDataPoint:IoTDeviceWriteColor_G value:@((int)(components[1] * 255))];
    [self writeDataPoint:IoTDeviceWriteColor_B value:@((int)(components[2] * 255))];
}

#pragma mark - AlerView methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1 && buttonIndex == 0)
    {
        IoTAppDelegate.hud.labelText = @"正在关灯...";
        [IoTAppDelegate.hud showAnimated:YES whileExecutingBlock:^{
            sleep(61);
        }];
        [self writeDataPoint:IoTDeviceWriteOnOff value:@0];
        [self writeDataPoint:IoTDeviceWriteUpdateData value:nil];
        self.btnShutdown.selected = NO;
    }
}

#pragma mark - HSVColorPickerDelegate methods
- (void)colorPicker:(HSVColorPicker *)colorPicker changedColor:(UIColor *)color {
    [self updateViewWithColor:color];
}

#pragma mark - Common methods
+ (IoTMainController *)currentController
{
    SlideNavigationController *navCtrl = [SlideNavigationController sharedInstance];
    for(int i=(int)(navCtrl.viewControllers.count-1); i>0; i--)
    {
        if([navCtrl.viewControllers[i] isKindOfClass:[IoTMainController class]])
            return navCtrl.viewControllers[i];
    }
    return nil;
}

#pragma mark - XPGWifiSDK delegate
- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didUnbindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage
{
    //解绑事件
    if([error intValue] == XPGWifiError_NONE)
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"解除绑定成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)XPGWifiDeviceDidDisconnected:(XPGWifiDevice *)device
{
    if(![device.did isEqualToString:self.device.did] || self.device.isConnected)
        return;
    [self onDisconnected];
}

//数据入口
- (void)XPGWifiDevice:(XPGWifiDevice *)device didReceiveData:(NSDictionary *)data result:(int)result{
    
    if(![device.did isEqualToString:self.device.did])
        return;
    
    [IoTAppDelegate.hud hide:YES];
    /**
     * 数据部分
     */
    NSDictionary *_data = [data valueForKey:@"data"];
    if(nil != _data)
    {
        NSString *onOff             = [self readDataPoint:IoTDeviceWriteOnOff data:_data];
        NSString *Mode              = [self readDataPoint:(IoTDeviceWriteMode) data:_data];
        NSString *C_Temperature     = [self readDataPoint:(IoTDeviceWriteC_Temperature) data:_data];
        NSString *Brightness        = [self readDataPoint:(IoTDeviceWriteBrightness) data:_data];
        NSString *Color_R           = [self readDataPoint:(IoTDeviceWriteColor_R) data:_data];
        NSString *Color_G           = [self readDataPoint:(IoTDeviceWriteColor_G) data:_data];
        NSString *Color_B           = [self readDataPoint:IoTDeviceWriteColor_B data:_data];
        
        
        bSwitch                     = [self prepareForUpdateFloat:onOff value:bSwitch];
        iMode                       = [self prepareForUpdateFloat:Mode value:iMode];
        iBrightness                 = [self prepareForUpdateFloat:Brightness value:iBrightness];
        iC_Temperature              = [self prepareForUpdateFloat:C_Temperature value:iC_Temperature];
        iColor_R                    = [self prepareForUpdateFloat:Color_R value:iColor_R];
        iColor_G                    = [self prepareForUpdateFloat:Color_G value:iColor_G];
        iColor_B                    = [self prepareForUpdateFloat:Color_B value:iColor_B];
        
        /**
         * 更新到 UI
         */
        [self setChangeC_TemperatureSliderValue:iC_Temperature];
        [self setChangeBrightnessSliderValue:iBrightness];
        
        UIColor * color = [UIColor colorWithRed:iColor_R/255.0 green:iColor_G/255.0 blue:iColor_B/255.0 alpha:1];
        self.colorPicker.color              = color;
        self.colorView.backgroundColor      = self.colorPicker.color;
        
        self.subView.userInteractionEnabled         = bSwitch;
        self.btnShutdown.selected                   = bSwitch;
        self.imageLightSlider.highlighted           = bSwitch;
        self.imageC_TemSlider.highlighted           = bSwitch;
        
        //开关灯状态下控件的颜色显示
        if (bSwitch) {
            [self selectMode:iMode sendToDevice:NO];
        }else{
            self.btnC_Temperature.selected          = bSwitch;
            self.btnColor.selected                  = bSwitch;
        }
    }
    return;
}

@end
