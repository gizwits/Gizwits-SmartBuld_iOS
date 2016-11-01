//
//  GosDeviceScheduleEditController.m
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceScheduleEditController.h"
#import "GosTimeSelectCell.h"
#import "GosDeviceScheduleActionController.h"
#import "GosDeviceScheduleRepeatController.h"
#import "GosCommon.h"
#import "GosTimingTaskDAL.h"
#import "GosDateTimeProcess.h"
#import "GosDataBaseManager.h"
#import "GosTipView.h"

// 预约界面
@interface GosDeviceScheduleEditController ()<UITableViewDelegate, UITableViewDataSource, GosTimeSelectCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) GosDeviceScheduleTask *data;
@property (nonatomic, assign) GosSubscribeStatus subscribeStatus;
@property (nonatomic, strong) GizWifiDevice *device;

@property (nonatomic, strong) GosTimingTaskDAL *timingTaskDAL;

@property (nonatomic, assign) int repeat;
@property (nonatomic, assign) BOOL task;
@property (nonatomic, assign) BOOL isSave;
@property (nonatomic, assign) int time;

@end

@implementation GosDeviceScheduleEditController

- (instancetype)initWithDevice:(GizWifiDevice *)device subscribeStatus:(GosSubscribeStatus)status withData:(GosDeviceScheduleTask *)data
{
    if (self = [super init])
    {
        self.device = device;
        self.subscribeStatus = status;
        if (status == GosSubscribeStatusUpdate)
        {
            // 更新的情况
            self.data = data;
            self.repeat = data.repeat;
            self.task = data.task;
            self.time = data.time;
        }
        else
        {
            // 添加的情况
            // 设置初始值
            self.data = [[GosDeviceScheduleTask alloc] init];
            self.data.task = YES;
            self.data.repeat = 0;
            self.data.date = 0;
            self.data.time = 0;
            self.data.isInCloud = NO;
            self.data.uid = [GosCommon sharedInstance].uid;
            self.data.did = self.device.did;
            self.data.rule_id = @"";
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpNavigaionBar];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    self.isSave = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isSave == NO)
    {
        self.data.repeat = self.repeat;
        self.data.task = self.task;
        self.data.time = self.time;
    }
}

- (void)setUpNavigaionBar
{
    self.navigationItem.title = NSLocalizedString(@"Reservation", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(save)];
}

- (void)save
{
    self.isSave = YES;
    NSLog(@"****************************点击保存****************************");
    
    // 更新日期
    [[GosTipView sharedInstance] showLoadTipWithMessage:NSLocalizedString(@"Setting timer...Please wait for a moment", nil)];
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        if (self.subscribeStatus == GosSubscribeStatusAdd)
        {
            // 添加的情况
            [[GosTimingTaskDAL sharedInstance] addTimingTask:self.data withToken:[GosCommon sharedInstance].token completion:^(int errorCode) {
                if (errorCode == 0)
                {
                    NSLog(@"成功添加一条定时任务");
                    
                    NSString *uid = [GosCommon sharedInstance].uid;
                    NSString *did = self.device.did;
                    [[GosDataBaseManager sharedInstance] searchDatasWithConditions:@{Uid:uid, Did:did} completion:^(NSArray *datas) {
                        
                        self.timingTaskDAL.datas = [NSMutableArray arrayWithArray:datas];
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Successfully set timer", nil) delay:1 completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    });
                }
                else
                {
                    NSLog(@"添加一条定时任务失败");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Failed to set timer", nil) delay:1 completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        
                    });
                }
            }];
        }
        else
        {
            // 更新的情况
            BOOL dataStatus = [self.data getTimingTaskStatus];
            NSString *token = [GosCommon sharedInstance].token;
            
            [[GosTimingTaskDAL sharedInstance] updateTimingTask:self.data timingTaskStatus:dataStatus withToken:token completion:^(int errorCode) {
                if (errorCode == 0)
                {
                    NSLog(@"更新数据成功");
                    NSString *uid = [GosCommon sharedInstance].uid;
                    NSString *did = self.device.did;
                    [[GosDataBaseManager sharedInstance] searchDatasWithConditions:@{Uid:uid, Did:did} completion:^(NSArray *datas) {
                        self.timingTaskDAL.datas = [NSMutableArray arrayWithArray:datas];
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Successfully set timer", nil) delay:1 completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Failed to set timer", nil) delay:1 completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        
                    });
                }
            }];
        }
        
    });
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 2;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *actionReuserIdentify = @"UITableViewCell";
    NSString *pickerReuserIdentify = @"GosTimeSelectCell";
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:actionReuserIdentify];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:actionReuserIdentify];
        }
        
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        switch (indexPath.row)
        {
            case 0:
            {
                cell.textLabel.text = NSLocalizedString(@"Action", nil);
                cell.detailTextLabel.text = self.data.task ? NSLocalizedString(@"ON", nil) : NSLocalizedString(@"OFF", nil);
                break;
            }
            case 1:
            {
                cell.textLabel.text = NSLocalizedString(@"repeat", nil);
                NSString *detailText = [self.data getTimingRemarkDate];
                if ([detailText isEqualToString:@""]
                    ||
                    [detailText isEqualToString:NSLocalizedString(@"Today", nil)]
                    ||
                    [detailText isEqualToString:NSLocalizedString(@"Tomorrow", nil)])
                {
                    detailText = NSLocalizedString(@"Once", nil);;
                }
                cell.detailTextLabel.text = detailText;
                break;
            }
            default:
                break;
        }
        return cell;
    }
    else if (indexPath.section == 1)
    {
        GosTimeSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:pickerReuserIdentify];
        if (cell == nil)
        {
            cell = [[GosTimeSelectCell alloc] initWithTimerScheduleType:GosTimeSelectTypeSchedule];
        }
        cell.delegate = self;
        cell.minutes = self.data.time;
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            return 50;
        case 1:
            return 216;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        self.isSave = YES;
        switch (indexPath.row)
        {
            case 0:
            {
                GosDeviceScheduleActionController *actionController = [[GosDeviceScheduleActionController alloc] initWithData:self.data];
                [self.navigationController pushViewController:actionController animated:YES];
                break;
            }
            case 1:
            {
                GosDeviceScheduleRepeatController *repeatWeekController = [[GosDeviceScheduleRepeatController alloc] initWithData:self.data];
                [self.navigationController pushViewController:repeatWeekController animated:YES];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - GosTimerScheduleCellDelegate
- (void)timerScheduleCell:(GosTimeSelectCell *)cell didSelectedMinutes:(NSInteger)minutes
{
    NSLog(@"****************************选择的时间是：%zd:%zd****************************", minutes / 60, minutes % 60);
    
    self.data.time = (int)minutes;
}

#pragma mark - properity
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

- (GosTimingTaskDAL *)timingTaskDAL
{
    return [GosTimingTaskDAL sharedInstance];
}

@end
