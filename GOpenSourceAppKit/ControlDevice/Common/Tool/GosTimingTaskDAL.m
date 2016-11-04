//
//  GosTimingTaskDAL.m
//  SmartSocket
//
//  Created by danly on 16/8/4.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosTimingTaskDAL.h"
#import "GosNetworkTool.h"
#import "GosDataBaseManager.h"
#import "GosDateTimeProcess.h"
#import "GosDeviceScheduleTask.h"
#import "GosDeviceControl.h"

@implementation GosTimingTaskDAL

+ (instancetype)sharedInstance
{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

#pragma mark - 数据更新处理
/**
 *  同步云端定时数据到本地
 *
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)cogradientCloudDataToDBWithToken:(NSString *)token withUid:(NSString *)uid Completion:(void (^)(int errorCode))completion
{
    // 查询所有云端数据
    [[GosNetworkTool sharedInstance] sendSearchTimingTaskWithToken:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
        if (errorCode == 0)
        {
            NSLog(@"查询到的云端数据: %@", responseData);
            
            if ([responseData isKindOfClass:[NSArray class]])
            {
                // 遍历云端数据，并存储到本地
                for (NSDictionary *cloudTask in responseData)
                {
                    
                    NSArray *tasks = cloudTask[CLOUDTASK_TASK];
                    NSDictionary *task = tasks.lastObject;
                    NSDictionary *attrs = task[CLOUDTASK_TASK_ATTRS];
                    
                    NSNumber *onOffNum = attrs[DATA_ATTR_POWER_SWITCH];
                    BOOL onOff = onOffNum.boolValue;
                    NSString *did = task[CLOUDTASK_DID];
                    NSString *timeStr = cloudTask[CLOUDTASK_TIME];
                    NSString *dateStr = cloudTask[CLOUDTASK_DATE];
                    NSString *repeatStr = cloudTask[CLOUDTASK_REPEAT];
                    NSString *rule_id = cloudTask[CLOUDTASK_ID];
                    BOOL isInCloud = YES;
                    
                    int time = [GosDateTimeProcess getTimeFromUTCTime:timeStr];
                    int repeat = (int)[GosDateTimeProcess weakRepeatFromRepeatStr:repeatStr withTime:time];
                    
                    
                    
                    // 更新该任务到数据库
                    GosDeviceScheduleTask *timingTask = [[GosDeviceScheduleTask alloc] init];
                    timingTask.rule_id = rule_id;
                    timingTask.task = onOff;
                    timingTask.did = did;
                    timingTask.uid = uid;
                    timingTask.time = time;
                    timingTask.repeat = repeat;
                    timingTask.isInCloud = isInCloud;
                    timingTask.date = [GosDateTimeProcess getCurrentDateWithCurrentZoneTime:time andUTCDate:dateStr];
                    
                    [[GosDataBaseManager sharedInstance] addData:[timingTask getDictionary]];
                    
                  
                }
                
                NSLog(@"添加云端数据到数据库成功");
                if (completion)
                {
                    completion(0);
                }
                
            }
        }
        else
        {
            NSLog(@"查询失败");
            if (completion)
            {
                completion(1);
            }
        }
    }];
 }

/**
 *  添加定时任务
 *
 *  @param data        定时任务
 *  @param token       token
 */
- (void)addTimingTask:(GosDeviceScheduleTask *)data withToken:(NSString *)token completion:(void (^)(int errorCode))completion
{
    // 重新设置最新的日期 - 防止仅一次的时候出现时间早于当前时间的情况
    data.date = [GosDateTimeProcess getIntDateWithRepeat:data.repeat WithTime:data.time];
    
    [[GosNetworkTool sharedInstance] sendCreateTimingRequestWithTime:data.time andDate:[GosDateTimeProcess getDateWithRepeat:data.repeat WithTime:data.time] andRepeat:data.repeat deviceDid:data.did andIsStart:data.task token:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
        
        if (errorCode == 0)
        {
            NSLog(@"创建定时任务成功");
            
            data.isInCloud = YES;  // 标志任务存在云端
            
            NSDictionary *rData = responseData;
            data.rule_id = rData[CLOUDTASK_ID];
            [[GosDataBaseManager sharedInstance] addData:[data getDictionary]];
            if (completion)
            {
                completion(0);
            }
        }
        else
        {
            NSLog(@"创建定时任务失败");
            if (completion)
            {
                completion(1);
            }
        }
        
    }];

}

/**
 *  删除定时任务
 *
 *  @param data       定时任务
 *  @param token      token
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)deleTimingTask:(GosDeviceScheduleTask *)data withToken:(NSString *)token completion:(void (^)(int errorCode))completion
{
   // 任务存在云端的情况，先删除云端，再删除本地
    if (data.isInCloud)
    {
        [[GosNetworkTool sharedInstance] sendDeleteTimingRequstWithID:data.rule_id withToken:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
           
            if (errorCode == 0 || errorCode == 9030)
            {
                NSLog(@"删除云端任务成功");
                // 删除本地数据
                [[GosDataBaseManager sharedInstance] deleteDataWithConditions:@{Rule_ID:data.rule_id}];
                
                if (completion)
                {
                    completion(0);
                }
            }
            else
            {
                NSLog(@"删除失败, %d, %@, %@", errorCode, errorMessage, detailErrorMessage);
                if (completion)
                {
                    completion(1);
                }
            }
            
        }];
        
        return;
    }
    else
    {
        // 不存在云端
        // 删除本地数据
        [[GosDataBaseManager sharedInstance] deleteDataWithConditions:@{Rule_ID:data.rule_id}];
        
        if (completion)
        {
            completion(0);
        }
    }
}

/**
 *  从打开到关闭状态
 *
 *  @param task       状态发生变化的定时任务
 *  @param token      token
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)closeTimingTask:(GosDeviceScheduleTask *)task withToken:(NSString *)token completion:(void (^)(int errorCode))completion
{
    //  先删除云端数据  再更新本地数据库
    [[GosNetworkTool sharedInstance] sendDeleteTimingRequstWithID:task.rule_id withToken:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
        if (errorCode == 0 || errorCode == 9030)
        {
            NSLog(@"删除云端数据成功");
            
            // 更新数据库任务的云端状态
            task.isInCloud = NO;
            [[GosDataBaseManager sharedInstance] updataWithConditions:@{Rule_ID: task.rule_id} withNewData:[task getDictionary]];
            
            if (completion)
            {
                completion(0);
            }
        }
        else
        {
            NSLog(@"删除云端数据失败");
            if (completion)
            {
                completion(1);
            }
        }
    }];
}

/**
 *  从关闭到打开的状态
 *
 *  @param task      状态发生变化的定时任务
 *  @param token     
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)openTimingTask:(GosDeviceScheduleTask *)task withToken:(NSString *)token completion:(void (^)(int errorCode))completion
{
    // 重新设置最新的日期 - 防止仅一次的时候出现时间早于当前时间的情况
    task.date = [GosDateTimeProcess getIntDateWithRepeat:task.repeat WithTime:task.time];
    
    // 先判断是否存在云端， 存在，先删除云端数据  创建云端任务， 更新本地数据库
    if (task.isInCloud)
    {
        // 存在云端
        [[GosNetworkTool sharedInstance] sendDeleteTimingRequstWithID:task.rule_id withToken:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
            if (errorCode == 0 || errorCode == 9030)
            {
                [self updateCloudAndDBWithTimingTask:task withToken:token completion:^(int errorCode) {
                    if (errorCode == 0)
                    {
                        if (completion)
                        {
                            completion(0);
                        }
                    }
                    else
                    {
                        if (completion)
                        {
                            completion(1);
                        }
                    }
                }];
            }
            else
            {
                if (completion)
                {
                    completion(1);
                }
            }
        }];
        
    }
    else
    {
        // 不存在云端， 创建云端数据， 更新本地数据库
        [self updateCloudAndDBWithTimingTask:task withToken:token completion:^(int errorCode) {
            if (errorCode == 0)
            {
                if (completion)
                {
                    completion(0);
                }
            }
            else
            {
                if (completion)
                {
                    completion(1);
                }
            }
        }];
    }
}

/**
 *  关闭到打开的过程中，云端不存在数据，本地存在数据时，创建云端，并更新本地相应数据
 *
 *  @param task        状态发生变化的定时任务
 *  @param token
 *  @param completion
 */
- (void)updateCloudAndDBWithTimingTask:(GosDeviceScheduleTask *)task withToken:(NSString *)token completion:(void (^)(int errorCode))completion
{
    // 创建云端任务
    [[GosNetworkTool sharedInstance] sendCreateTimingRequestWithTime:task.time andDate:[GosDateTimeProcess getDateWithRepeat:task.repeat WithTime:task.time] andRepeat:task.repeat deviceDid:task.did andIsStart:task.task token:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
        if (errorCode == 0)
        {
            // 创建成功
            task.isInCloud = YES;
            NSDictionary *rData = responseData;
            
            NSString *oldRule_id = task.rule_id;
            task.rule_id = rData[CLOUDTASK_ID];
            
            // 更新数据库内容
            [[GosDataBaseManager sharedInstance] updataWithConditions:@{Rule_ID:oldRule_id} withNewData:[task getDictionary]];
            
            if (completion)
            {
                completion(0);
            }
        }
        else
        {
            if (completion)
            {
                completion(1);
            }
        }
    }];
}

/**
 *  更新定时任务
 *
 *  @param task       需要更新的定时任务
 *  @param status     定时任务当前的状态  开启/关闭
 *  @param token
 *  @param completion 完成回调 errorCode = 0，添加成功， 否则，添加失败
 */
- (void)updateTimingTask:(GosDeviceScheduleTask *)task timingTaskStatus:(BOOL)status withToken:(NSString *)token completion:(void (^)(int errorCode))completion
{
    // 重新设置最新的日期 - 防止仅一次的时候出现时间早于当前时间的情况
    task.date = [GosDateTimeProcess getIntDateWithRepeat:task.repeat WithTime:task.time];
    
    if (status == NO)
    {
        // 1.在关闭状态时更新
        // 是否存在云端， 存在，删除云端 创建新的定时任务并更新到本地
        // 不存在， 创建新的定时任务并更新到本地
        [self openTimingTask:task withToken:token completion:^(int errorCode) {
            if (errorCode == 0)
            {
                if (completion)
                {
                    completion(0);
                }
            }
            else
            {
                if (completion)
                {
                    completion(1);
                }
            }
        }];
    }
    else
    {
        // 2.在打开状态时更新
        // 删除云端任务， 创建新的定时任务并更新到本地
        [[GosNetworkTool sharedInstance] sendDeleteTimingRequstWithID:task.rule_id withToken:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
            if (errorCode == 0 || errorCode == 9030)
            {
                [self updateCloudAndDBWithTimingTask:task withToken:token completion:^(int errorCode) {
                    if (errorCode == 0)
                    {
                        if (completion)
                        {
                            completion(0);
                        }
                    }
                    else
                    {
                        if (completion)
                        {
                            completion(1);
                        }
                    }
                }];
            }
            else
            {
                if (completion)
                {
                    completion(1);
                }
            }
        }];
    }
}


@end
