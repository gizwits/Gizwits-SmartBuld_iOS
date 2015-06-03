/**
 * AppDelegate.m
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

#import "AppDelegate.h"
#import "IoTMainController.h"
#import "IoTMainMenu.h"
#import "IoTAlertView.h"

// App ID 和 Product Key
static NSString * const IOT_APPKEY = @"2675d8b7962c413c86780fa88ed9ce6e";
NSString * const IOT_PRODUCT       = @"781aebb40640490fbd1a4f2e0e5774ac";

@interface AppDelegate ()
{
    IoTProcessModel *model;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"]];
    model = [IoTProcessModel startWithAppID:IOT_APPKEY product:IOT_PRODUCT productJson:data];
    model.delegate = self;
    
    //用户未注册-->登录
    //用户已注册-->设备列表
    if(nil == self.window)
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.backgroundColor = [UIColor whiteColor];
        //这条不能省略
        model.window = self.window;
    }
    
    //主界面
    self.navCtrl = [[SlideNavigationController alloc] initWithRootViewController:model.loginController];
    self.navCtrl.leftMenu = [[IoTMainMenu alloc] init];//主菜单部分
    self.navCtrl.navigationBar.tintColor = [UIColor whiteColor];
    self.navCtrl.navigationBar.barTintColor = [UIColor colorWithRed:0.1484375 green:0.49609375 blue:0.90234375 alpha:1.00];

    model.tintColor = self.navCtrl.navigationBar.tintColor;
    model.barTintColor = self.navCtrl.navigationBar.barTintColor;
    
    self.navCtrl.navigationBar.translucent = NO;
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.window.rootViewController = self.navCtrl;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - call tel 10086
- (void)callServices
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://10086"]];
}

#pragma mark IoTProcessModel delegate
- (void)IoTProcessModelDidLogin:(NSInteger)result
{
    if(result == 0)
    {
        //登录后，跳到设备列表页面
        [self.navCtrl pushViewController:model.deviceListController animated:YES];
    }
}

- (void)IoTProcessModelDidControlDevice:(XPGWifiDevice *)device
{
    if(device.isConnected){
        if(device.isOnline)
        {
            //设备连接后，跳转到控制页面
            IoTMainController *mainCtrl = [[IoTMainController alloc] initWithDevice:device];
            [self.navCtrl pushViewController:mainCtrl animated:YES];
        }
    }
}

- (void)IoTProcessModelDidFinishedAddDevice:(NSInteger)result
{
    if(result != 0)
    {
        //未能删除
        NSString *message = [NSString stringWithFormat:@"无法绑定此设备，错误码：%@", @(result)];
        [[[IoTAlertView alloc] initWithMessage:message delegate:nil titleOK:nil] show:YES];
    }
}

- (void)IoTProcessModelDidUserLogout:(NSInteger)result
{
    [self.hud hide:YES];
    
    if(result == 0)
    {
        if(self.navCtrl.viewControllers.count > 1)
            [self.navCtrl popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSString *message = [NSString stringWithFormat:@"注销失败，错误码：%@", @(result)];
        [[[IoTAlertView alloc] initWithMessage:message delegate:nil titleOK:nil] show:YES];
    }
}

#pragma mark - Properties
- (MBProgressHUD *)hud
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.window];
    if(nil == hud)
    {
        hud = [[MBProgressHUD alloc] initWithWindow:self.window];
        [self.window addSubview:hud];
    }
    return hud;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [IoTAppDelegate.hud hide:YES];
    
    //如果进入主页按home键，则自动退出
    BOOL isMainCtrl = NO;
    IoTDeviceList *deviceListCtrl = nil;
    for(UIViewController *controller in self.navCtrl.viewControllers)
    {
        if([controller isKindOfClass:[IoTDeviceList class]])
            deviceListCtrl = (IoTDeviceList *)controller;
        
        if([controller isKindOfClass:[IoTMainController class]])
        {
            isMainCtrl = YES;
            break;
        }
    }
    
    if(isMainCtrl)
    {
        if(deviceListCtrl)
            [self.navCtrl popToViewController:deviceListCtrl animated:YES];
        else
            [self.navCtrl popToRootViewControllerAnimated:YES];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
