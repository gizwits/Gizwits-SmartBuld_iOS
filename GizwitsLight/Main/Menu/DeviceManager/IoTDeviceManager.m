/**
 * IoTDeviceManager.m
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

#import "IoTDeviceManager.h"
#import "IoTDeviceDetail.h"
#import "IoTAlertView.h"
#import "IoTMainController.h"

@interface IoTDeviceManager () <UITableViewDelegate, UITableViewDataSource, XPGWifiDeviceDelegate>
{
    //设备列表
    NSArray *deviceList;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//选中设备的管理，防止页面跳转或者其他意外的情况出现引用错误指针Crash的情况
@property (strong, nonatomic) XPGWifiDevice *selectedDevice;

@end

@implementation IoTDeviceManager

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"设备管理";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    //进到这个页面的时候，先清空其他设备的delegate
    for(XPGWifiDevice *device in [self arrayList])
        device.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //清除选中设备的状态
    self.selectedDevice.delegate = nil;
    self.selectedDevice = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBack
{
    XPGWifiDevice *dev = [self getDevice];
    if(dev == nil){
        [self exitToDeviceList];
    }else{
        [self exitToMainCtrl:dev];
    }
}

#pragma mark - DeviceManager
- (NSInteger)deviceCount
{
    return ((NSArray *)deviceList[0]).count+((NSArray *)deviceList[2]).count;
}

- (NSArray *)arrayList
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:deviceList[0]];
    [array addObjectsFromArray:deviceList[2]];
    return [NSArray arrayWithArray:array];
}

- (void)pushToDetail:(XPGWifiDevice *)device
{
    IoTDeviceDetail *detailCtrl = [[IoTDeviceDetail alloc] initWithDevice:device];
    [self.navigationController pushViewController:detailCtrl animated:YES];
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    deviceList = [IoTProcessModel sharedModel].devicesList;
    return [self deviceCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *strIdentifier = @"deviceManagerIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if(nil == cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    
    //设备列表
    NSArray *arrayList = [self arrayList];
    
    self.selectedDevice.delegate = nil;
    XPGWifiDevice *device = (XPGWifiDevice *)arrayList[indexPath.row];
    self.selectedDevice = device;
    if(device.remark.length == 0)
        cell.textLabel.text = device.productName;
    else
        cell.textLabel.text = device.remark;
    
    if(device.isOnline){
        cell.textLabel.textColor = [UIColor colorWithRed:41/255.f green:142/255.f blue:238/255.f alpha:1];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //判断是否在线
    if(device.isOnline)
        cell.imageView.image = [UIImage imageNamed:@"menu_88"];
    else
        cell.imageView.image = [UIImage imageNamed:@"menu_88"];
    
    //登录设备
    [self toLoginDeivce];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //设备列表
    NSArray *arrayList = [self arrayList];
    
    XPGWifiDevice *device = (XPGWifiDevice *)arrayList[indexPath.row];
    if(!device.isConnected)
    {
        IoTAppDelegate.hud.labelText = @"连接中...";
        [IoTAppDelegate.hud show:YES];
        
        device.delegate = self;
        [device login:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken];
    }
    else
    {
        [self pushToDetail:device];
    }
}

#pragma mark - XPGWifiDeviceDelegate
- (void)XPGWifiDevice:(XPGWifiDevice *)device didLogin:(int)result
{
    [IoTAppDelegate.hud hide:YES];
    
    if(result == 0)
    {
        [self pushToDetail:device];
    }
    else
    {
        //登录失败
        NSString *message = [NSString stringWithFormat:@"登录失败，错误码：%i", result];
        [[[IoTAlertView alloc] initWithMessage:message delegate:nil titleOK:nil] show:YES];
    }
}

//退到设备列表
- (void)exitToDeviceList{
    //退出到列表
    for(int i=(int)(self.navigationController.viewControllers.count-1); i>0; i--)
    {
        UIViewController *controller = self.navigationController.viewControllers[i];
        if([controller isKindOfClass:[IoTDeviceList class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)exitToMainCtrl:(XPGWifiDevice *)dev{
    IoTMainController *mainCtrl = [IoTMainController currentController];
    mainCtrl.device = dev;
    [self.navigationController popToViewController:mainCtrl animated:YES];
}

- (XPGWifiDevice *)getDevice{
    NSArray *onlineDeviceList = deviceList[0];
    if ([onlineDeviceList count] == 0){
        return nil;
    }
    
    //如果选中的设备未连接，或者已经解除绑定
    XPGWifiDevice *oldDevice = [IoTMainController currentController].device;
    NSInteger index = [onlineDeviceList indexOfObject:oldDevice];
    if(index >= onlineDeviceList.count || oldDevice.isConnected != YES)
    {
        //选择第一个在线的设备
        return onlineDeviceList[0];
    }
    return oldDevice;
}

- (void)onDeivceLogin:(XPGWifiDevice *)dev{
    [dev login:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken];
}

- (void)toLoginDeivce{
    XPGWifiDevice *device = [self getDevice];
    if(device == nil){
        return ;
    }
    [self onDeivceLogin:device];
}

@end
