//
//  GosDelayController.m
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDelayController.h"
#import "GosTimeSelectCell.h"
#import "GosDeviceControl.h"

// 延时关闭界面
@interface GosDelayController ()<UITableViewDataSource,UITableViewDelegate,GosTimeSelectCellDelegate>

@property (nonatomic, strong) GosDeviceControl *deviceControl;
@property (nonatomic, assign) NSInteger selectedMinutes;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation GosDelayController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    
    self.deviceControl = [GosDeviceControl sharedInstance];
    
    [self setUpNavigaionBar];
    
}

- (void)setUpNavigaionBar
{
    self.navigationItem.title = NSLocalizedString(@"Light off timer", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    if (self.deviceControl.countDownOffMin != 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.selectedMinutes = 1;
    }
}

- (void)save
{
    [self.deviceControl writeDataPoint:GosDeviceWriteCountDownOffMin value:@(self.selectedMinutes)];
    [self.deviceControl writeDataPoint:GosDeviceWriteCountDownSwitch value:@(YES)];
    
    self.deviceControl.countDownOffMin = (int)self.selectedMinutes;
    self.deviceControl.countDownSwitch = YES;
    [self.deviceControl postDataUpdateNotification];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuserIdentify = @"GosTimeSelectCell";
    GosTimeSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserIdentify];
    if (cell == nil)
    {
        cell = [[GosTimeSelectCell alloc] initWithTimerScheduleType:GosTimeSelectTypeDelay];
    }
    cell.delegate = self;
    cell.minutes = self.deviceControl.countDownOffMin;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 245;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Device will turn off automatically after timer stops", nil);
}

#pragma mark - GosTimerScheduleCellDelegate
- (void)timerScheduleCell:(GosTimeSelectCell *)cell didSelectedMinutes:(NSInteger)minutes
{
    self.selectedMinutes = minutes;
    if (self.deviceControl.countDownOffMin != minutes)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}


- (UITableView *)tableView
{
    if (!_tableView)
    {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height) style:UITableViewStyleGrouped];
        _tableView = tb;
        [self.view addSubview:_tableView];
        
    }
    return _tableView;
}


@end
