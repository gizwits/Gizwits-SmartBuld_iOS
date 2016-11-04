//
//  GosDeviceViewController.m
//  SmartLight
//
//  Created by danly on 16/7/26.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceViewController.h"
#import "HSVColorPicker.h"
#import "GosDeviceControl.h"
#import "UIColor+HexCodes.h"
#import "GosMoreController.h"
#import "GosTimingTaskDAL.h"

@interface GosDeviceViewController ()<HSVColorPickerDelegate, GizWifiDeviceDelegate>

@property (nonatomic, strong) GizWifiDevice *device;
@property (nonatomic, strong) UIViewController *deviceListController;

@property (weak, nonatomic) IBOutlet UIButton *closeLight;
@property (weak, nonatomic) IBOutlet UIButton *goBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
@property (weak, nonatomic) IBOutlet UIButton *modeBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *countDownView;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *smallCircleColorView;

// 色环
// 色彩环
@property (weak, nonatomic) IBOutlet HSVColorPicker *hueColorPicker;
// 色温环
@property (weak, nonatomic) IBOutlet RGBColorPicker *rgbColorPicker;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlide;

// 约束值
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewWidthCon;

// 读写控制器
@property (nonatomic, strong) GosDeviceControl *deviceControlTool;

// 线程
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, copy) NSString *deviceName;

@end

@implementation GosDeviceViewController

+ (instancetype)deviceControllerWithDevice:(GizWifiDevice *)device withDeviceListController:(UIViewController *)deviceListController;
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GosDeviceViewController" bundle:[NSBundle mainBundle]];
    GosDeviceViewController *deviceController = sb.instantiateInitialViewController;
    deviceController.deviceListController = deviceListController;
    deviceController.device = device;
    
    return deviceController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpNavigaionBar];
    [self setupUI];
    [self drawCircle];

    self.deviceControlTool = [GosDeviceControl sharedInstance];
    self.deviceControlTool.device = self.device;
    
    self.hueColorPicker.delegate = self;
    self.rgbColorPicker.delegate = self;
    self.device.delegate = self;

    self.titleLabel.text = [self deviceName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:GosDeviceControlDataValueUpdateNotification object:nil];
    
    // 初始化设备数据
    [self.deviceControlTool initDevice];
    
    // 同步云端的数据
    [self getCloudTaskToDataBase];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    [self checkDeviceStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.queue cancelAllOperations];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc
{
    [self.device setSubscribe:NO];
    
    [[GosTipView sharedInstance] hideTipView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUI
{
    // 更新模式按钮 切换色环
    GosDeviceModeType modeType = self.deviceControlTool.mode;
    
    self.modeBtn.selected = modeType;
    self.rgbColorPicker.hidden = !modeType;
    self.hueColorPicker.hidden = modeType;
    
    if (modeType == GosDeviceModeColor)
    {
        //色彩模式
        CGFloat red = self.deviceControlTool.colorRed / 255.0;
        CGFloat green = self.deviceControlTool.colorGreen / 255.0;
        CGFloat blue = self.deviceControlTool.colorBlue / 255.0;
        self.hueColorPicker.color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        self.smallCircleColorView.backgroundColor = self.hueColorPicker.color;
    }
    else
    {
         // 色温模式
        CGFloat red = self.deviceControlTool.temperatureRed / 255.0;
        CGFloat green = self.deviceControlTool.temperatureGreen / 255.0;
        CGFloat blue = self.deviceControlTool.temperatureBlue / 255.0;
        self.rgbColorPicker.color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        self.smallCircleColorView.backgroundColor = self.rgbColorPicker.color;
    }
    self.brightnessSlide.value = self.deviceControlTool.brightness;
    
    // 更新灯
    if (self.deviceControlTool.powerSwitch == YES)
    {
        // 开灯
        self.coverView.hidden = YES;
        self.closeLight.hidden = NO;
        self.goBackBtn.hidden = NO;
        self.menuBtn.hidden = NO;
        self.countDownView.hidden = !self.deviceControlTool.countDownSwitch;
        self.countDownLabel.text = [NSString stringWithFormat:@"%zd%@", self.deviceControlTool.countDownOffMin,NSLocalizedString(@"minutes later", nil)];

    }
    else
    {
        // 关灯
        self.coverView.hidden = NO;
        self.closeLight.hidden = YES;
        self.goBackBtn.hidden = YES;
        self.menuBtn.hidden = YES;
        self.countDownView.hidden = YES;
    }
    
}

// 检查设备状态
- (void)checkDeviceStatus
{
    
    if (self.device.netStatus == GizDeviceControlled)
    {
        // 设备可控获取设备状态
        [[GosTipView sharedInstance] hideTipView];
        [self.device getDeviceStatus];
        
        return;
    }
    
    [[GosTipView sharedInstance] showLoadTipWithMessage:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Waiting for device connection", nil)]];
    
    // 开启一个子线程 检测设备状态
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
        int timeInterval = self.device.isLAN ? 10 : 20;
        
        // 小循环延时 10s / 大循环延时 20s
        [NSThread sleepForTimeInterval:timeInterval];
        
        if (![weakOperation isCancelled])
        {
            if (self.device.netStatus != GizDeviceControlled)
          {
                // 10s后 设备不可控，退到设备列表
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[GosTipView sharedInstance] hideTipView];
                    // 退到设备列表
                    if (self.navigationController.viewControllers.lastObject == self)
                    {
                        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"No response from device,Please check the running state of device", nil)  delay:1 completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }
                });
                
            }
            else
            {
                // 可控，获取设备状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.device getDeviceStatus];
                    
                });
            }
            
            // 关闭所有线程
            [self.queue cancelAllOperations];
        }
        
    }];
    
    // 取消其它所有正在检测设备网络状态的线程
    if (self.queue.operationCount > 0)
    {
        [self.queue cancelAllOperations];
    }
    [self.queue addOperation:operation];
    
}

- (void)setUpNavigaionBar
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUI
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (screenWidth == 320 && screenHeight == 480)
    {
        // iPhone4/4s
        self.colorViewWidthCon.constant = 27;
    }
    else
    {
        // 5以上型号的手机， 底部视图占屏幕的 比例  80 / 568
        self.colorViewWidthCon.constant = (33.0 / 568) * screenHeight;
    }
}

#pragma mark - Action
- (IBAction)goBackDeviceList:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuBtnDidClick
{
    GosMoreController *moreController = [[GosMoreController alloc] initWithDevice:self.device];
    moreController.deviceListViewController = self.deviceListController;
    [self.navigationController pushViewController:moreController animated:YES];
}

// 模式按钮被点击
- (IBAction)modeBtnDidClcik:(UIButton *)modeBtn
{
    NSLog(@"****************************切换模式****************************");
    
    modeBtn.selected = !modeBtn.selected;
    BOOL typeMode = modeBtn.selected;
    
    self.rgbColorPicker.hidden = !typeMode;
    self.hueColorPicker.hidden = typeMode;
    
    self.deviceControlTool.mode = typeMode;
    [self.deviceControlTool writeDataPoint:GosDeviceWriteMode value:@(typeMode)];
    [self updateUI];
}

- (IBAction)slideStopDrag:(UISlider *)sender
{
    
    self.deviceControlTool.brightness = sender.value;
    [self.deviceControlTool writeDataPoint:GosDeviceWriteBrightness value:@(sender.value)];
    [self updateUI];
}


// 关灯
- (IBAction)closeLightBtnDidClick
{
    self.coverView.hidden = NO;
    self.closeLight.hidden = YES;
    self.goBackBtn.hidden = YES;
    self.menuBtn.hidden = YES;
    
    self.deviceControlTool.powerSwitch = NO;
    [self.deviceControlTool writeDataPoint:GosDeviceWritePowerSwitch value:@(NO)];
    [self updateUI];
}

// 开灯
- (IBAction)turnOnLight
{
    self.coverView.hidden = YES;
    self.closeLight.hidden = NO;
    self.goBackBtn.hidden = NO;
    self.menuBtn.hidden = NO;
    
    self.deviceControlTool.powerSwitch = YES;
    [self.deviceControlTool writeDataPoint:GosDeviceWritePowerSwitch value:@(YES)];
    [self updateUI];
}



#pragma mark - GizWifiDeviceDelegate
- (void)device:(GizWifiDevice *)device didReceiveData:(NSError *)result data:(NSDictionary *)dataMap withSN:(NSNumber *)sn
{
    [[GosTipView sharedInstance] hideTipView];
    
    // 获取设备状态，或者设备主动上报
    NSDictionary *data = [dataMap valueForKey:@"data"];
    
    if(nil != data && [data count] != 0)
    {
        [self.deviceControlTool readDataPointsFromData:data];
        [self.deviceControlTool postDataUpdateNotification];
    }
}

- (void)device:(GizWifiDevice *)device didUpdateNetStatus:(GizWifiDeviceNetStatus)netStatus
{
    NSLog(@"****************************网络状态回调接口: %@****************************", [NSThread currentThread]);
    
//    NSLog(@"netStatus = %zd", netStatus);
    if (netStatus == GizDeviceControlled)
    {
        [self.queue cancelAllOperations];
        [[GosTipView sharedInstance] hideTipView];
        [self.device getDeviceStatus];
        return;
    }
    
//    netStatus = 2;
//    NSLog(@"netStatus = %zd", netStatus);
    if (netStatus != GizDeviceControlled && self.navigationController.viewControllers.lastObject == self)
    {
        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Unable to access the device", nil)  delay:1 completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - HSVColorPickerDelegate
- (void)colorPicker:(HSVColorPicker *)colorPicker changedColor:(UIColor *)color
{
    CGFloat colorRed;
    CGFloat colorGreen;
    CGFloat colorBlue;
    [color getColorWithRed:&colorRed withGreen:&colorGreen withBlue:&colorBlue];
    
    if (self.deviceControlTool.mode == GosDeviceModeColor)
    {
        self.deviceControlTool.colorRed = colorRed;
        self.deviceControlTool.colorBlue = colorBlue;
        self.deviceControlTool.colorGreen = colorGreen;
    }
    else
    {
        self.deviceControlTool.temperatureRed = colorRed;
        self.deviceControlTool.temperatureBlue = colorBlue;
        self.deviceControlTool.temperatureGreen = colorGreen;
    }
    
    [self.deviceControlTool writeColor:colorRed colorG:colorGreen colorB:colorBlue];
    self.smallCircleColorView.backgroundColor = color;
}


- (void)getCloudTaskToDataBase
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [path.firstObject stringByAppendingPathComponent:@"LoadingMarkFile.plist"];
    
    NSMutableArray *loadingMarks = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    if (loadingMarks == nil)
    {
        loadingMarks = [NSMutableArray array];
    }
    NSString *uid = [GosCommon sharedInstance].uid;
    BOOL isLoading = NO;
    for (NSString *tempUid in loadingMarks)
    {
        if ([tempUid isEqualToString:uid])
        {
            isLoading = YES;
            break;
        }
    }
    
    if (!isLoading)
    {
        dispatch_async(dispatch_queue_create(0, 0), ^{
            [[GosTimingTaskDAL sharedInstance] cogradientCloudDataToDBWithToken:[GosCommon sharedInstance].token withUid:[GosCommon sharedInstance].uid Completion:^(int errorCode) {
                if (errorCode == 0)
                {
                    // 同步成功
                    [loadingMarks addObject:uid];
                    [loadingMarks writeToFile:filePath atomically:YES];
                }
            }];
        });
    }
}

#pragma mark - 画圆
- (void)drawCircle
{
    self.smallCircleColorView.layer.cornerRadius = self.colorViewWidthCon.constant / 2;

}

- (NSOperationQueue *)queue
{
    if (_queue == nil)
    {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSString *)deviceName
{
    NSString *tempName = nil;
    if (self.device.alias == nil || [self.device.alias isEqualToString:@""])
    {
        tempName = self.device.productName;
    }
    else
    {
        tempName = self.device.alias;
    }
    
    if (tempName.length > 10)
    {
        tempName = [tempName substringWithRange:NSMakeRange(0, 10)];
        tempName = [NSString stringWithFormat:@"%@...", tempName];
    }
    return tempName;
}

@end
