//
//  GosDeviceScheduleRepeatController.m
//  SmartSocket
//
//  Created by danly on 16/8/2.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceScheduleRepeatController.h"
#import "GosDeviceRepeatSelectCell.h"
#import "GosNetworkTool.h"
#import "GosDateTimeProcess.h"

@interface GosDeviceScheduleRepeatController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) GosDeviceScheduleTask *data;
@property (nonatomic, assign) int repeat;

@end

@implementation GosDeviceScheduleRepeatController

- (instancetype)initWithData:(GosDeviceScheduleTask *)data
{
    if (self = [super init])
    {
        self.data = data;
        self.repeat = data.repeat;
        
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

- (void)setUpNavigaionBar
{
    self.navigationItem.title = NSLocalizedString(@"repeat", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(save)];
}

- (void)save
{
    self.data.repeat = self.repeat;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
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
            cell.title = NSLocalizedString(@"Every Sunday", nil);
            cell.select = [self isSelectWithweekDay:WEAK_REPEAT_SUNDAY];
            break;
        }
        case 1:
        {
            cell.title = NSLocalizedString(@"Every Monday", nil);
            cell.select = [self isSelectWithweekDay:WEAK_REPEAT_MONDAY];
            break;
        }
        case 2:
            cell.title = NSLocalizedString(@"Every Tuesday", nil);
            cell.select = [self isSelectWithweekDay:WEAK_REPEAT_TUESDAY];
            break;
        case 3:
            cell.title = NSLocalizedString(@"Every Wednesday", nil);
            cell.select = [self isSelectWithweekDay:WEAK_REPEAT_WEDNESDAY];
            break;
        case 4:
            cell.title = NSLocalizedString(@"Every Thursday", nil);
            cell.select = [self isSelectWithweekDay:WEAK_REPEAT_THURSDAY];
            break;
        case 5:
            cell.title = NSLocalizedString(@"Every Friday", nil);
            cell.select = [self isSelectWithweekDay:WEAK_REPEAT_FRIDAY];
            break;
        case 6:
            cell.title = NSLocalizedString(@"Every Saturday", nil);
            cell.select = [self isSelectWithweekDay:WEAK_REPEAT_SATURDAY];
            break;
        default:
            break;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GosDeviceRepeatSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.select = !cell.select;
    
    switch (indexPath.row)
    {
        case 0:
        {
            [self updateRepeatWithSelect:cell.select andweekDay:WEAK_REPEAT_SUNDAY];
            break;
        }
        case 1:
        {
            [self updateRepeatWithSelect:cell.select andweekDay:WEAK_REPEAT_MONDAY];
            break;
        }
        case 2:
        {
            [self updateRepeatWithSelect:cell.select andweekDay:WEAK_REPEAT_TUESDAY];
            break;
        }
        case 3:
        {
            [self updateRepeatWithSelect:cell.select andweekDay:WEAK_REPEAT_WEDNESDAY];
            break;
        }
        case 4:
        {
            [self updateRepeatWithSelect:cell.select andweekDay:WEAK_REPEAT_THURSDAY];
            break;
        }
        case 5:
        {
            [self updateRepeatWithSelect:cell.select andweekDay:WEAK_REPEAT_FRIDAY];
            break;
        }
        case 6:
        {
            [self updateRepeatWithSelect:cell.select andweekDay:WEAK_REPEAT_SATURDAY];
            break;
        }
        default:
            break;
    }
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

- (void)updateRepeatWithSelect:(BOOL)select andweekDay:(int)weekDay
{
    if (select)
    {
        self.repeat += weekDay;
    }
    else
    {
        self.repeat -= weekDay;
    }
}

- (BOOL)isSelectWithweekDay:(int)weekday
{
    if (self.repeat & weekday)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
