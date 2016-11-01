//
//  GosDeviceScheduleTask.h
//  SmartSocket
//
//  Created by danly on 16/8/3.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GosDeviceScheduleTask : NSObject

@property (nonatomic, assign) int ID;
@property (nonatomic, copy) NSString *rule_id;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *did;
@property (nonatomic, assign, readwrite) BOOL task;
@property (nonatomic, assign) int time;
@property (nonatomic, assign) int date;
@property (nonatomic, assign) int repeat;
@property (nonatomic, assign) BOOL isInCloud;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (NSMutableArray *)timingTasks:(NSArray *)dics;

- (NSDictionary *)getDictionary;
- (NSArray *)dicsFromTimingTasks:(NSArray *)timingTasks;


/**
 *  获取定时任务的备注时间
 *
 *  @return 备注时间
 */
- (NSString *)getTimingRemarkDate;

/**
 *  获取定时任务的 状态  开启/关闭
 *
 *  @return 状态  YES:开启  NO:关闭
 */
- (BOOL)getTimingTaskStatus;

- (NSArray *)repeatIndexes;

@end
