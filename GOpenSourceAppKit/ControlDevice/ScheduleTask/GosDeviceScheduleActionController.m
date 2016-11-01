//
//  GosDeviceScheduleActionController.m
//  SmartSocket
//
//  Created by danly on 16/8/2.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceScheduleActionController.h"
#import "GosDeviceRepeatSelectCell.h"

// 预约动作界面
@interface GosDeviceScheduleActionController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) GosDeviceScheduleTask *data;

@end

@implementation GosDeviceScheduleActionController

- (instancetype)initWithData:(GosDeviceScheduleTask *)data
{
    if (self = [super init])
    {
        self.data = data;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
}

- (void)setUpNavigaionBar
{
    self.navigationItem.title = NSLocalizedString(@"Action", nil);
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentify = @"GosDeviceRepeatSelectCell";
    GosDeviceRepeatSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentify];
    
    if (cell == nil)
    {
        cell = [[GosDeviceRepeatSelectCell alloc] init];
    }
    
    switch (indexPath.row)
    {
        case 0:
        {
            cell.title = NSLocalizedString(@"ON", nil);
            cell.select = self.data.task;
            break;
        }
        case 1:
        {
            cell.title = NSLocalizedString(@"OFF", nil);
            cell.select = !self.data.task;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 0:
            self.data.task = YES;
            break;
        case 1:
            self.data.task = NO;
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(250 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
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

@end
