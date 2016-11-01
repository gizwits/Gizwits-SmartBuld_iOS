//
//  GosMoreController.h
//  SmartSocket
//
//  Created by danly on 16/7/28.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosMoreController.h"
#import "GosModifyDeviceNameController.h"
#import "GosTipView.h"
#import "GosAlertView.h"
#import <GizWifiSDK/GizWifiSDK.h>
#import "GosCommon.h"
#import "GosDeviceScheduleController.h"
#import "GosMoreCell.h"
#import "GosDelayCell.h"
#import "GosDelayController.h"
#import "GosDeviceControl.h"

#define GosMoreCellReuserIdentify @"GosMoreCellReuserIdentify"
#define GosDelayCellReuserIdentify @"GosDelayCellReuserIdentify"

// 更多界面
@interface GosMoreController ()<UITableViewDelegate, UITableViewDataSource, GosAlertViewDelegate, GizWifiSDKDelegate, GosSchedullCloseCellDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic, strong) GizWifiDevice *device;

// 解除设备绑定按钮
@property (nonatomic, weak) UIButton *unBindingBtn;

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, strong) GosDeviceControl *deviceCotrol;

@end

@implementation GosMoreController

- (instancetype)initWithDevice:(GizWifiDevice *)device;
{
    if (self = [super init])
    {
        self.device = device;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpNavigaionBar];
    
    self.view.backgroundColor = [UIColor colorWithRed:BackgroundRedColor green:BackgroundGreenColor blue:BackgroundBlueColor alpha:1];
    
    self.deviceCotrol = [GosDeviceControl sharedInstance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"GosDelayCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:GosDelayCellReuserIdentify];
    [self.tableView registerNib:[UINib nibWithNibName:@"GosMoreCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:GosMoreCellReuserIdentify];
    
    self.unBindingBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.unBindingBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-40]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.unBindingBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.unBindingBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:260]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.unBindingBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:GosDeviceControlDataValueUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [GizWifiSDK sharedInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [GizWifiSDK sharedInstance].delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpNavigaionBar
{
    self.navigationItem.title = NSLocalizedString(@"More", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.navigationItem.title style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource And UITableDeleagte
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        GosMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:GosMoreCellReuserIdentify forIndexPath:indexPath];
        cell.iconName = @"more_icon_name";
        cell.title = NSLocalizedString(@"Modify the device name", nil);
        cell.deviceName = self.deviceName;
        return cell;
    }
    else if (indexPath.row == 1)
    {
        GosMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:GosMoreCellReuserIdentify forIndexPath:indexPath];
        cell.iconName = @"more_icon_schedules";
        cell.title = NSLocalizedString(@"Timer On/Off", nil);
        cell.deviceName = @"";
        return cell;
    }
    else
    {
        GosDelayCell *cell = [tableView dequeueReusableCellWithIdentifier:GosDelayCellReuserIdentify forIndexPath:indexPath];
        cell.delegate = self;
        cell.iconName = @"more_icon_timer";
        cell.title = NSLocalizedString(@"Light off timer", nil);
        
        int minutes;
    
        minutes = (int)self.deviceCotrol.countDownOffMin;
    
        cell.time = [NSString stringWithFormat:@"%d%@", minutes, NSLocalizedString(@"minutes later", nil)];
        cell.isOn = self.deviceCotrol.countDownSwitch;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row)
    {
        case 0:
        // 修改设备名称
        {
            if (self.device.isBind)
            {
                GosModifyDeviceNameController *modiftDeviceController = [[GosModifyDeviceNameController alloc] initWithDevice:self.device];
                modiftDeviceController.deviceListViewController = self.deviceListViewController;
                [self.navigationController pushViewController:modiftDeviceController animated:YES];
            }
            else
            {
                [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Device not bound", nil) delay:1 completion:nil];
            }
            NSLog(@"修改设备名称");
            break;
        }
        case 1:
            // 定时预约
        {
            GosDeviceScheduleController *scheduleController = [[GosDeviceScheduleController alloc] initWithDevice:self.device];
            [self.navigationController pushViewController:scheduleController animated:YES];
            break;
        }
        case 2:
        // 延时关闭
        {
            GosDelayController *delayCloseVC = [[GosDelayController alloc] init];
            [self.navigationController pushViewController:delayCloseVC animated:YES];
            break;
        }
        default:
        break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSString *)deviceName
{
    if (self.device.alias == nil || [self.device.alias isEqualToString:@""])
    {
        return self.device.productName;
    }
    return self.device.alias;
}

#pragma mark - SDKDelegate
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUnbindDevice:(NSError *)result did:(NSString *)did
{
    [[GosTipView sharedInstance] hideTipView];
    if (result.code == 0)
    {
        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Remove binding", nil) delay:1 completion:^{
            
            [self.navigationController popToViewController:self.deviceListViewController animated:YES];
        }];
    }
    else
    {
        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Unbinding fail", nil) delay:1 completion:nil];
    }
}

- (void)unBindingDeviceClick
{
    [[[GosAlertView alloc] initWithMessage:[NSString stringWithFormat:@"%@?",NSLocalizedString(@"Sure you want to remove binding device", nil)] delegate:self titleOK:NSLocalizedString(@"OK", nil) titleCancel:NSLocalizedString(@"NO", nil)] show:YES];
}

- (void)GosAlertViewDidDismissButton:(GosAlertView *)alertView withButton:(BOOL)isConfirm
{
    
    if (isConfirm)
    {
        if (!self.device.isBind)
        {
            // 设备没被绑定
            [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Device not bound", nil) delay:1 completion:nil];
            
            return;
        }
        
        [[GizWifiSDK sharedInstance] unbindDevice:[GosCommon sharedInstance].uid token:[GosCommon sharedInstance].token did:self.device.did];
        [[GosTipView sharedInstance] showLoadTipWithMessage:NSLocalizedString(@"Unbinding the device", nil)];
    
    }
}

#pragma mark - GosSchedullCloseCellDelegate
- (void)schedullCloseCell:(GosDelayCell *)cell switchValueChange:(UISwitch *)schedullSwitch
{
    if (schedullSwitch.isOn)
    {
        if (self.deviceCotrol.countDownOffMin == 0)
        {
            // 跳转到第二个界面
            schedullSwitch.on = NO;
            GosDelayController *schedullCloseVC = [[GosDelayController alloc] init];
            [self.navigationController pushViewController:schedullCloseVC animated:YES];
        }
        else
        {
            // 下发数据点数据
            [self.deviceCotrol writeDataPoint:GosDeviceWriteCountDownSwitch value:@(schedullSwitch.isOn)];
            self.deviceCotrol.countDownSwitch = schedullSwitch.isOn;
            [self.deviceCotrol postDataUpdateNotification];
        }
    }
    else
    {
        [self.deviceCotrol writeDataPoint:GosDeviceWriteCountDownSwitch value:@(NO)];
    }
 
}

- (void)updateUI
{
    [self.tableView reloadData];
}


#pragma mark - properties
- (UITableView *)tableView
{
    if (!_tableView )
    {
        UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 55 * 5) style:UITableViewStyleGrouped];
        
        _tableView = tb;
        [self.view addSubview:tb];
    }
    return _tableView;
}

- (UIButton *)unBindingBtn
{
    if (!_unBindingBtn)
    {
        UIButton *btn = [[UIButton alloc] init];
        [btn setBackgroundImage:[UIImage imageNamed:@"more_btn_unbundling"] forState:UIControlStateNormal];
//        Unbinding
        [btn setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Unbinding", nil)] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(unBindingDeviceClick) forControlEvents:UIControlEventTouchUpInside];
        _unBindingBtn = btn;
    }
    return _unBindingBtn;
}


@end
