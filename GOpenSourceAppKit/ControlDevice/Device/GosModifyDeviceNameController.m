//
//  GosModifyDeviceNameController.m
//  SmartSocket
//
//  Created by danly on 16/7/28.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosModifyDeviceNameController.h"
#import "GosModifyDeviceNameCell.h"
#import <GizWifiSDK/GizWifiSDK.h>

// 修改设备名称界面
@interface GosModifyDeviceNameController ()<UITableViewDelegate, UITableViewDataSource,GizWifiDeviceDelegate, UITextFieldDelegate>

@property (nonatomic, strong) GizWifiDevice *device;
@property (weak, nonatomic) UITableView *tableView;

@property (nonatomic, strong) GosModifyDeviceNameCell *deviceEditCell;
@property (nonatomic, copy) NSString *deviceName;

@end

@implementation GosModifyDeviceNameController

- (instancetype)initWithDevice:(GizWifiDevice *)device
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
    
    // 设置导航栏
    [self setUpNavigaionBar];
    
    self.deviceName = self.device.alias;
    
    // 设置代理
    self.device.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.view.backgroundColor = [UIColor colorWithRed:BackgroundRedColor green:BackgroundGreenColor blue:BackgroundBlueColor alpha:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 弹出键盘，并添加 编辑 文本框的监听
    if (self.deviceEditCell)
    {
        [self.deviceEditCell.textField becomeFirstResponder];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanging:) name:@"UITextFieldTextDidChangeNotification" object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)setUpNavigaionBar
{
    self.navigationItem.title = NSLocalizedString(@"Device name", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)save
{
    [self.view endEditing:YES];
    [self.device setCustomInfo:nil alias:self.deviceEditCell.textField.text];
    [[GosTipView sharedInstance] showLoadTipWithMessage:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"updating data", nil)]];
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 设置别名界面
    if (!self.deviceEditCell)
    {
        self.deviceEditCell = [[GosModifyDeviceNameCell alloc] init];
        
        self.deviceEditCell.textField.text = [self showDeviceName];
        self.deviceEditCell.textField.delegate = self;
    }
    
    return self.deviceEditCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Please enter the device name", nil);
}


- (NSString *)showDeviceName
{
    if ([self.device.alias isEqualToString:@""] || self.device.alias == nil)
    {
        return self.device.productName;
    }
    return self.device.alias;
}


- (void)device:(GizWifiDevice *)device didSetCustomInfo:(NSError *)result
{
    [[GosTipView sharedInstance] hideTipView];
    if (result.code == 0)
    {
        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Succeed to set data", nil) delay:1 completion:^{
            [self.navigationController popToViewController:self.deviceListViewController animated:YES];
        }];
    }
    else
    {
        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Fail to set data", nil) delay:1 completion:nil];
    }
}

#pragma mark - TextFieldDelegate and Notification
- (void)textFieldChanging:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    if ([toBeString isEqualToString:self.deviceName] || toBeString == nil || toBeString.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        // 输入的字符限制在16
        NSString *toBeString = textField.text;
        
        // 获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > 16)
            {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
                if (rangeIndex.length == 1)
                {
                    textField.text = [toBeString substringToIndex:16];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                    textField.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - properity
- (UITableView *)tableView
{
    if (!_tableView)
    {
        UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200) style:UITableViewStyleGrouped];
        _tableView = tb;
        _tableView.scrollEnabled = NO;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
