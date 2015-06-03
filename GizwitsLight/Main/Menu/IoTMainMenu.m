/**
 * IoTMainMenu.m
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

#import "IoTMainMenu.h"
#import "IoTAccountManager.h"
#import "IoTDeviceManager.h"
#import "IoTHelp.h"
#import "IoTAbout.h"
#import "IoTMainController.h"

#import "SlideNavigationController.h"

@interface IoTMainMenu () <UITableViewDataSource, UITableViewDelegate, XPGWifiDeviceDelegate>
{
    //主要的功能
    NSArray *subItems;
    
    //设备列表
    NSArray *deviceList;
}

@end

@implementation IoTMainMenu

- (void)viewDidLoad
{
    [super viewDidLoad];
    subItems = @[@"设备管理", @"账号管理", @"帮助", @"关于"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushToViewController:(UIViewController *) controller
{
    SlideNavigationController *navCtrl = [SlideNavigationController sharedInstance];
    [navCtrl closeMenuWithCompletion:^{
        
    }];
    [navCtrl pushViewController:controller animated:YES];
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

- (void)setNetworkAvailable:(BOOL)available
{
    self.view.userInteractionEnabled = !available;
    [SlideNavigationController sharedInstance].view.userInteractionEnabled = !available;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:available];
}

- (void)switchToDevice:(XPGWifiDevice *)device
{
    IoTMainController *mainCtrl = [IoTMainController currentController];
    if(nil == mainCtrl)
    {
        NSLog(@"[IoTMainController currentController] cause error, abort.");
        abort();
    }
    
    //更新新设备的数据
    mainCtrl.device = device;
    mainCtrl.device.delegate = (id<XPGWifiDeviceDelegate>)mainCtrl;
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
    [mainCtrl writeDataPoint:IoTDeviceWriteUpdateData value:nil];
    
    //重新加载
    NSMutableArray *array = [NSMutableArray array];
    for(int i=0; i<[self deviceCount]; i++)
    {
        [array addObject:[NSIndexPath indexPathForRow:i+1 inSection:0]];
    }
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
- (IBAction)onBack:(id)sender
{
    SlideNavigationController *navCtrl = [SlideNavigationController sharedInstance];
    [navCtrl closeMenuWithCompletion:^{
        
    }];
    
    IoTMainController *mainCtrl = nil;
    for(int i=(int)(navCtrl.viewControllers.count-1); i>0; i--)
    {
        UIViewController *controller = navCtrl.viewControllers[i];
        if([controller isKindOfClass:[IoTMainController class]])
            mainCtrl = (IoTMainController *)controller;

        if([controller isKindOfClass:[IoTDeviceList class]])
        {
            //在这里不清理 delegate 就会 Crash
            mainCtrl.device.delegate = nil;
            [navCtrl popToViewController:controller animated:YES];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    deviceList = [IoTProcessModel sharedModel].devicesList;
    return subItems.count+[self deviceCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentifier = @"mainMenuIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if(nil == cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    
    //合并的设备
    NSArray *arrayList = [self arrayList];
    
    //设备个数
    NSInteger deviceCount = arrayList.count;
    
    //重置相关属性
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;

    
    if(indexPath.row == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_88"];
        cell.textLabel.text = subItems[indexPath.row];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"device_list-32"]];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    if(indexPath.row > 0 && indexPath.row < deviceCount+1)
    {
        //设备
        IoTMainController *mainCtrl = [IoTMainController currentController];
        if(nil == mainCtrl)
        {
            NSLog(@"[IoTMainController currentController] cause error, abort.");
            abort();
        }

        
        XPGWifiDevice *device = arrayList[indexPath.row-1];
        NSString *productName = device.remark;
        
        if(device.remark.length == 0)
            productName = device.productName;

        cell.textLabel.text = [NSString stringWithFormat:@"         %@", productName];
        cell.textLabel.textColor = [UIColor blackColor];
        if(device.isOnline){
            cell.textLabel.textColor = [UIColor colorWithRed:0/255.f green:186/255.f blue:147/255.f alpha:1];
        }
        
        
        //标记为marked
        cell.tintColor = [UIColor colorWithRed:0/255.f green:186/255.f blue:147/255.f alpha:1];
        cell.accessoryType = mainCtrl.device == device ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    //账号管理
    if(indexPath.row == deviceCount+1)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_88-02"];
        cell.textLabel.text = subItems[indexPath.row-deviceCount];
        cell.textLabel.textColor = [UIColor blackColor];
    }

    //帮助
    if(indexPath.row == deviceCount+2)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_88-03"];
        cell.textLabel.text = subItems[indexPath.row-deviceCount];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    //关于
    if(indexPath.row == deviceCount+3)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_88-04"];
        cell.textLabel.text = subItems[indexPath.row-deviceCount];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    
    //在这里，加'>'符号
    if(indexPath.row > deviceCount)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //合并的设备
    NSArray *arrayList = [self arrayList];
    
    //设备个数
    NSInteger deviceCount = arrayList.count;
    
    if(indexPath.row == 0)
    {
        //设备管理
        IoTDeviceManager *deviceManager = [[IoTDeviceManager alloc] init];
        [self pushToViewController:deviceManager];
        [self.view setUserInteractionEnabled:NO];
    }
    if(indexPath.row > 0 && indexPath.row < deviceCount+1)
    {
        //切换设备，锁定状态，不允许用户随便乱点
        [self setNetworkAvailable:YES];
        
        XPGWifiDevice *device = arrayList[indexPath.row-1];
        device.delegate = self;
        
        //判断设备是否在线，不能切换离线设备
        if(!device.isOnline){
            [self setNetworkAvailable:NO];
            return ;
        }
        
        //如果已经连接则直接设置
        if(device.isConnected)
        {
            [self switchToDevice:device];
            [self setNetworkAvailable:NO];
            return;
        }
        
        //登录
        [device login:[IoTProcessModel sharedModel].currentUid token:[IoTProcessModel sharedModel].currentToken];
    }
    if(indexPath.row == deviceCount+1)
    {
        //账号管理
        IoTAccountManager *accountManager = [[IoTAccountManager alloc] init];
        [self pushToViewController:accountManager];
        [self.view setUserInteractionEnabled:NO];
    }
    if(indexPath.row == deviceCount+2)
    {
        //帮助

            IoTHelp *helpCtrl = [[IoTHelp alloc] init];
            [self pushToViewController:helpCtrl];
            [self.view setUserInteractionEnabled:NO];
    }
    if(indexPath.row == deviceCount+3)
    {
        //关于
        IoTAbout *aboutCtrl = [[IoTAbout alloc] init];
        [self pushToViewController:aboutCtrl];
        [self.view setUserInteractionEnabled:NO];
    }
    [self performSelector:@selector(startViewAction) withObject:nil afterDelay:1];
}

- (void)startViewAction{
    [self.view setUserInteractionEnabled:YES];
}

#pragma mark - XPGWifiDeviceDelegate
- (void)XPGWifiDevice:(XPGWifiDevice *)device didLogin:(int)result
{
    device.delegate = nil;
    
    //登录成功
    if(result == 0)
    {
        [self switchToDevice:device];
    }
    
    //重置状态
    [self setNetworkAvailable:NO];
}

- (BOOL)isPushCurrentController{
    
    IoTMainController *mainCtrl = [IoTMainController currentController];

    for (UIViewController *controller in mainCtrl.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[IoTMainController class]]) {
            return YES;
        }
    }
    return NO;
}

@end
