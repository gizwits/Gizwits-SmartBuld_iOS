/**
 * IoTProcessModel.h
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
#import <XPGWifiSDK/XPGWifiSDK.h>
#import "IoTLogin.h"
#import "IoTDeviceList.h"

@protocol IoTProcessModelDelegate <NSObject>
@optional

/**
 * @brief 用户账号登录完成事件
 * @param result 完成的结果
 */
- (void)IoTProcessModelDidLogin:(NSInteger)result;

/**
 * @brief 添加设备完成事件，也就是有关绑定的事件会推送到这里
 * @param result 完成的结果
 */
- (void)IoTProcessModelDidFinishedAddDevice:(NSInteger)result;

/**
 * @brief 设备连接后，可以控制时，开发者自行切换界面即可
 * @param device 设备句柄
 */
- (void)IoTProcessModelDidControlDevice:(XPGWifiDevice *)device;

/**
 * @brief 注销事件
 * @param result 完成的结果
 */
- (void)IoTProcessModelDidUserLogout:(NSInteger)result;

/**
 * @brief 获取列表自定义图片
 */
- (UIImage *)IoTProcessModelGetDeviceImage:(XPGWifiDevice *)device section:(NSInteger)section;

/**
 * @brief 获取列表自定义显示名
 * @note SDK 默认的做法为 device.remark
 * @note 如果 device.remark 为空则取 device.productName
 */
- (NSString *)IoTProcessModelGetDeviceCustomText:(XPGWifiDevice *)device;

@end

@interface IoTProcessModel : NSObject<XPGWifiSDKDelegate>

- (id)init NS_UNAVAILABLE;

/**
 * @brief 单例模式
 */
+ (IoTProcessModel *)sharedModel;

/**
 * @brief 初始化
 * @param appid：用于 SDK 初始化的字符串
 * @param product：用于搜索设备时过滤 product key
 * @param data：product json
 * @result 非空则成功
 */
+ (IoTProcessModel *)startWithAppID:(NSString *)appid product:(NSString *)product productJson:(NSData *)data;

/**
 * @brief 初始化中控
 * @param appid：用于 SDK 初始化的字符串
 * @param products 包含两个设备的信息
 *  {
 *      "CentralDevice":
 *      {
 *          "ProductKey": [ProductKey],
 *          "Data": [Data]
 *      },
 *      "SubDevice":
 *      {
 *          "ProductKey": [ProductKey],
 *          "Data": [Data]
 *      }
 *  }
 *
 * @result 非空则成功
 */
+ (IoTProcessModel *)startWithAppID:(NSString *)appid withCentralProducts:(NSDictionary *)products;

/**
 * @brief 在 Delegate 中，实现快速入口完成的事件
 */
@property (nonatomic, assign) id <IoTProcessModelDelegate>delegate;

/**
 * @brief 是否注册
 */
@property (nonatomic, assign, readonly) BOOL isRegisteredUser;

/**
 * @brief 导航
 */
@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *tintColor;

/**
 * @brief 当前已登录的用户名、uid、token
 */
@property (nonatomic, strong, readonly) NSString *currentUser;
@property (nonatomic, strong, readonly) NSString *currentUid;
@property (nonatomic, strong, readonly) NSString *currentToken;

/**
 * @brief 获取通过设备列表最后一次发现的所有设备
 * @result @[已注册但设备, 新设备, 离线设备]
 */
@property (nonatomic, strong) NSArray *devicesList;

/**
 * @brief 注销
 * @note 调用此函数不管什么情况都会让登陆状态变成已注销状态
 */
- (void)logout;

/**
 * @brief Window，用于生成 MBProgressHUD 句柄，必须设置
 */
@property (nonatomic, strong) UIWindow *window;

/**
 * @brief 自动登录
 */
- (void)login;

/**
 * @brief 验证用户是电话还是邮箱，还是什么都不是
 */
- (BOOL)validatePhone:(NSString *)phone;
- (BOOL)validateEmail:(NSString *)email;
- (BOOL)validatePassword:(NSString *)password;

/**
 * @brief 登录页面
 */
- (IoTLogin *)loginController;

/**
 * @brief 设备列表页面
 */
- (IoTDeviceList *)deviceListController;

@end