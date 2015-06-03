/**
 * IoTDeviceDetail.m
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

#import "IoTDeviceDetail.h"
#import "IoTDeviceManager.h"
#import "IoTAlertView.h"

@interface IoTDeviceDetail () <XPGWifiDeviceDelegate, XPGWifiSDKDelegate, UITextFieldDelegate>

@property (nonatomic, strong) XPGWifiDevice *device;

//设备信息
@property (weak, nonatomic) IBOutlet UILabel *textHWInfo;

//可支持修改设备名称
@property (weak, nonatomic) IBOutlet UITextField *textProductName;

@end

@implementation IoTDeviceDetail

- (id)initWithDevice:(XPGWifiDevice *)device
{
    self = [super init];
    if(self)
    {
        self.device = device;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"设备管理";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onConfirm)];
    
    //设备名称
    if(self.device.remark.length == 0)
        self.textProductName.text = @"";
    else
        self.textProductName.text = self.device.remark;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [XPGWifiSDK sharedInstance].delegate = self;
    self.device.delegate = self;
    
    //小循环请求设备信息
    if(self.device.isOnline && self.device.isLAN)
        [self.device getHardwareInfo];
    else
        self.textHWInfo.text = @"无设备信息\n\n\n\n\n\n\n";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [XPGWifiSDK sharedInstance].delegate = nil;
    self.device.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)onBack
{
    [self exitToDeviceManager];
}

- (void)onConfirm
{
    const char *productName = [self.textProductName.text cStringUsingEncoding:NSUTF8StringEncoding];
    BOOL isAllSpace = NO;
    for(int i=0; i<self.textProductName.text.length; i++)
    {
        if(productName[i] == ' ')
        {
            if(i == 0)
                isAllSpace = YES;
        }
        else
        {
            if(isAllSpace == YES)
                isAllSpace = NO;
            break;
        }
    }
    
    if(isAllSpace)
    {
        //全都是空格？
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"输入的名称不能全部是空格" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    [self.textProductName resignFirstResponder];
    
    IoTAppDelegate.hud.labelText = @"正在更新设备名...";
    [IoTAppDelegate.hud show:YES];
    
    [[XPGWifiSDK sharedInstance] bindDeviceWithUid:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken did:self.device.did passCode:self.device.passcode remark:self.textProductName.text];
}

- (IBAction)onDelete:(id)sender
{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备删除后需要重新配置才能控制，是否确定继续删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [deleteAlert show];
}

- (IBAction)onTap:(id)sender
{
    [self.textProductName resignFirstResponder];
}

#pragma mark - text field
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    frame.origin.y = -100;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    frame.origin.y = 64;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.textProductName)
    {
        [textField resignFirstResponder];
        [self onConfirm];
    }
    
    return YES;
}

#pragma mark - XPGWifiDeviceDelegate
- (void)XPGWifiDevice:(XPGWifiDevice *)device didQueryHardwareInfo:(NSDictionary *)hwInfo
{
    if(!hwInfo)
    {
        self.textHWInfo.text = @"获取设备信息失败。\n\n\n\n\n\n\n";
    }
    else
    {
        self.textHWInfo.text = [NSString stringWithFormat:@"WiFi Hardware Version: %@,\n\
WiFi Software Version: %@\n\
MCU Hardware Version: %@\n\
MCU Software Version: %@\n\
Firmware Id: %@\n\
Firmware Version: %@\n\
Product Key: %@\n\
Device ID: %@", [hwInfo valueForKey:XPGWifiDeviceHardwareWifiHardVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareWifiSoftVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUHardVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUSoftVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareIdKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareVerKey]
                                  , [hwInfo valueForKey:XPGWifiDeviceHardwareProductKey], self.device.did];
    }
}

- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didBindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage
{
    //更新别名
    if([error intValue] == 0)
    {
        //更新列表
        IoTAppDelegate.hud.labelText = @"更新列表...";
        [[XPGWifiSDK sharedInstance] getBoundDevicesWithUid:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken specialProductKeys:IOT_PRODUCT, nil];
    }
    else
    {
        //未能更新
        [IoTAppDelegate.hud hide:YES];
        NSString *message = [NSString stringWithFormat:@"无法为此设备设置别名，错误码：%@", error];
        [[[IoTAlertView alloc] initWithMessage:message delegate:nil titleOK:nil] show:YES];
    }
}

- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didUnbindDevice:(NSString *)did error:(NSNumber *)error errorMessage:(NSString *)errorMessage
{
    //删除设备
    if([error intValue] == 0)
    {
        [IoTAppDelegate.hud hide:YES];
        //更新列表
        IoTAppDelegate.hud.labelText = @"更新列表...";
        [[XPGWifiSDK sharedInstance] getBoundDevicesWithUid:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken specialProductKeys:IOT_PRODUCT, nil];
    }
    else
    {
        [IoTAppDelegate.hud hide:YES];
        //未能删除
        NSString *message = [NSString stringWithFormat:@"无法删除此设备，错误码：%@", error];
        [[[IoTAlertView alloc] initWithMessage:message delegate:nil titleOK:nil] show:YES];
    }
}

- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didDiscovered:(NSArray *)deviceList result:(int)result
{
    //分类
    NSMutableArray
    *arr1 = [NSMutableArray array], //在线
    *arr2 = [NSMutableArray array], //新设备
    *arr3 = [NSMutableArray array]; //不在线
    
    for(XPGWifiDevice *device in deviceList)
    {
        if (device.isDisabled)
            continue;

        if(device.isLAN && ![device isBind:[IoTProcessModel sharedModel].currentUid])
        {
            [arr2 addObject:device];
            continue;
        }
        
        if(device.isLAN || device.isOnline)
        {
            [arr1 addObject:device];
            continue;
        }
        [arr3 addObject:device];
    }
    
    [IoTProcessModel sharedModel].devicesList = @[arr1, arr2, arr3];

    [IoTAppDelegate.hud performSelector:@selector(hide:) withObject:@YES afterDelay:0.2];
    
    //0.2s后自动退回到列表
    [self performSelector:@selector(onBack) withObject:nil afterDelay:0.2];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [alertView didMoveToSuperview];
    }else if(buttonIndex == 1){
        IoTAppDelegate.hud.labelText = @"删除中...";
        [IoTAppDelegate.hud show:YES];
        [[XPGWifiSDK sharedInstance] unbindDeviceWithUid:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken did:self.device.did passCode:self.device.passcode];
    }
}

//退到设备列表
- (void)exitToDeviceManager{
    //退出到列表
    for(int i=(int)(self.navigationController.viewControllers.count-1); i>0; i--)
    {
        UIViewController *controller = self.navigationController.viewControllers[i];
        if([controller isKindOfClass:[IoTDeviceManager class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

@end
