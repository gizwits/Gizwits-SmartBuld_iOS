//
//  GosTimingTaskDAL.h
//  SmartSocket
//
//  Created by danly on 16/8/4.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GosDataBaseManager.h"
#import "GosDeviceScheduleTask.h"

@interface GosTimingTaskDAL : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSMutableArray *datas;

/**
 *  同步云端定时数据到本地
 *
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)cogradientCloudDataToDBWithToken:(NSString *)token withUid:(NSString *)uid Completion:(void (^)(int errorCode))completion;

/**
 *  添加定时任务
 *
 *  @param data        定时任务
 *  @param token       token
 */
- (void)addTimingTask:(GosDeviceScheduleTask *)data withToken:(NSString *)token completion:(void (^)(int errorCode))completion;


/**
 *  删除定时任务
 *
 *  @param data       定时任务
 *  @param token      token
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)deleTimingTask:(GosDeviceScheduleTask *)data withToken:(NSString *)token completion:(void (^)(int errorCode))completion;

/**
 *  从打开到关闭状态
 *
 *  @param task       状态发生变化的定时任务
 *  @param token      token
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)closeTimingTask:(GosDeviceScheduleTask *)task withToken:(NSString *)token completion:(void (^)(int errorCode))completion;

/**
 *  从关闭到打开的状态
 *
 *  @param task      状态发生变化的定时任务
 *  @param token
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)openTimingTask:(GosDeviceScheduleTask *)task withToken:(NSString *)token completion:(void (^)(int errorCode))completion;


/**
 *  更新定时任务
 *
 *  @param task       需要更新的定时任务
 *  @param status     定时任务当前的状态  开启/关闭
 *  @param token
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)updateTimingTask:(GosDeviceScheduleTask *)task timingTaskStatus:(BOOL)status withToken:(NSString *)token completion:(void (^)(int errorCode))completion;

@end
