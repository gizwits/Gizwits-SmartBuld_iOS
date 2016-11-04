//
//  GosDeviceScheduleController.m
//  SmartSocket
//
//  Created by danly on 16/7/29.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceScheduleController.h"
#import "GosDeviceScheduleCell.h"
#import "GosDeviceScheduleEditController.h"
#import "GosTimingTaskDAL.h"
#import "GosCommon.h"


// 定时预约界面
@interface GosDeviceScheduleController ()<UITableViewDelegate, UITableViewDataSource, GosScheduleCellDelegate>

@property (nonatomic, strong) GizWifiDevice *device;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 没数据时显示的view
@property (weak, nonatomic) IBOutlet UIView *unDataView;

@property (nonatomic, strong) GosTimingTaskDAL *timingTaskDAL;


@end

@implementation GosDeviceScheduleController

- (instancetype)initWithDevice:(GizWifiDevice *)device
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GosDeviceScheduleController" bundle:[NSBundle mainBundle]];
    GosDeviceScheduleController *scheduleController = sb.instantiateInitialViewController;
    scheduleController.device = device;
    
    return scheduleController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpNavigaionBar];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // 隐藏tableView多余的cell
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    // 获取该设备的定时数据
    [[GosDataBaseManager sharedInstance] searchDatasWithConditions:@{Uid: [GosCommon sharedInstance].uid, Did:self.device.did} completion:^(NSArray *datas) {
        self.timingTaskDAL.datas = [NSMutableArray arrayWithArray:datas];
        
        [self.tableView reloadData];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

// 添加定时预约
- (IBAction)addTimerSubscribe
{
    GosDeviceScheduleEditController *subscribeController = [[GosDeviceScheduleEditController alloc] initWithDevice:self.device subscribeStatus:GosSubscribeStatusAdd withData:nil];
    [self.navigationController pushViewController:subscribeController animated:YES];
}

- (void)setUpNavigaionBar
{
    self.navigationItem.title = NSLocalizedString(@"Timer On/Off", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.navigationItem.title style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self setUnDataViewVisable];
    return self.timingTaskDAL.datas.count;
}

static NSString *reuserIdentify = @"GosDeviceScheduleCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GosDeviceScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserIdentify];
    if (cell == nil)
    {
        cell = [[GosDeviceScheduleCell alloc] init];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    GosDeviceScheduleTask *data = self.timingTaskDAL.datas[indexPath.row];

    NSLog(@"data = %@", data);
    cell.isStartScheduleTask = data.task;
    cell.time = [NSString stringWithFormat:@"%02i:%02i", data.time / 60, data.time % 60];
    cell.remark = [data getTimingRemarkDate];
    cell.isStart = [data getTimingTaskStatus];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - tableView左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_queue_create(0, 0), ^{
        
        
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            // 删除
            GosDeviceScheduleTask *data = self.timingTaskDAL.datas[indexPath.row];
            
            [[GosTimingTaskDAL sharedInstance] deleTimingTask:data withToken:[GosCommon sharedInstance].token completion:^(int errorCode) {
                if (errorCode == 0)
                {
                    NSLog(@"成功删除了一行");
                    [self.timingTaskDAL.datas removeObject:data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
   
                        [self.tableView reloadData];
                    });
                }
            }];
        }
    });
   
}


#pragma mark - GosScheduleCellDelegate
- (void)scheduleCellDidSelect:(GosDeviceScheduleCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    GosDeviceScheduleTask *data = self.timingTaskDAL.datas[indexPath.row];
    
    GosDeviceScheduleEditController *subscribeController = [[GosDeviceScheduleEditController alloc] initWithDevice:self.device subscribeStatus:GosSubscribeStatusUpdate withData:data];
    [self.navigationController pushViewController:subscribeController animated:YES];
}

- (void)scheduleCell:(GosDeviceScheduleCell *)cell switchValueChange:(UISwitch *)scheduleSwitch
{
    scheduleSwitch.userInteractionEnabled = NO;

    if (scheduleSwitch.isOn)
    {
        [[GosTipView sharedInstance] showLoadTipWithMessage:NSLocalizedString(@"Setting timer...Please wait for a moment", nil)];
    }
    
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    GosDeviceScheduleTask *data = self.timingTaskDAL.datas[indexPath.row];
    NSLog(@"第%zd行", indexPath.row);
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        if(scheduleSwitch.isOn)
        {
            // 关闭到打开
            [self.timingTaskDAL openTimingTask:data withToken:[GosCommon sharedInstance].token completion:^(int errorCode) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (errorCode == 0)
                    {
                        NSLog(@"打开成功");
                        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Successfully set timer", nil) delay:1 completion:^{
                            scheduleSwitch.userInteractionEnabled = YES;
                        }];
                    }
                    else
                    {
                        NSLog(@"打开失败");
                        [[GosTipView sharedInstance] showTipMessage:NSLocalizedString(@"Failed to set timer", nil) delay:1 completion:^{
                            scheduleSwitch.userInteractionEnabled = YES;
                        }];
                    }
                });
               
                
                [[GosDataBaseManager sharedInstance] searchDatasWithConditions:@{Uid: [GosCommon sharedInstance].uid, Did:self.device.did} completion:^(NSArray *datas) {
                    self.timingTaskDAL.datas = [NSMutableArray arrayWithArray:datas];
                }];
            }];
        }
        else
        {
            // 打开到关闭
            
            [self.timingTaskDAL closeTimingTask:data withToken:[GosCommon sharedInstance].token completion:^(int errorCode) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (errorCode == 0)
                    {
                        NSLog(@"关闭成功");
                    }
                    else
                    {
                        NSLog(@"关闭失败");
                    }
                    scheduleSwitch.userInteractionEnabled = YES;
                });
                
                [[GosDataBaseManager sharedInstance] searchDatasWithConditions:@{Uid: [GosCommon sharedInstance].uid, Did:self.device.did} completion:^(NSArray *datas) {
                    self.timingTaskDAL.datas = [NSMutableArray arrayWithArray:datas];
                }];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    });
    
}

// 设置无数据视图的可视性
- (void)setUnDataViewVisable
{
    if (self.timingTaskDAL.datas.count == 0)
    {
        self.unDataView.hidden = NO;
    }
    else
    {
        self.unDataView.hidden = YES;
    }
}

- (GosTimingTaskDAL *)timingTaskDAL
{
    return [GosTimingTaskDAL sharedInstance];
}


@end
