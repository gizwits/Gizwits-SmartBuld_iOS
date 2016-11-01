//
//  GosDeviceScheduleCell.h
//  SmartSocket
//
//  Created by danly on 16/7/29.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GosDeviceScheduleCell;
@protocol GosScheduleCellDelegate <NSObject>

- (void)scheduleCell:(GosDeviceScheduleCell *)cell switchValueChange:(UISwitch *)scheduleSwitch;
- (void)scheduleCellDidSelect:(GosDeviceScheduleCell *)cell;

@end

@interface GosDeviceScheduleCell : UITableViewCell

/**
 *  YES, 表示是开启的定时任务，  NO， 表示是关闭的定时任务
 */
@property (nonatomic, assign) BOOL isStartScheduleTask;

/**
 *  启动定时任务的时间
 */
@property (nonatomic, copy) NSString *time;

/**
 *  重复的天数
 */
@property (nonatomic, strong) NSString *remark;

/**
 *  YES， 此时的定时任务处于开启状态， NO， 此时的定时任务处于关闭状态
 */
@property (nonatomic, assign) BOOL isStart;

@property (nonatomic, weak) id<GosScheduleCellDelegate> delegate;




@end
