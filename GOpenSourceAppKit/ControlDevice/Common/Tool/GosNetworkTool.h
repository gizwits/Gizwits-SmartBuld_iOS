//
//  GosNetworkTool.h
//  SmartSocket
//
//  Created by danly on 16/7/13.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#define requestUrl @"http://api.gizwits.com/app/scheduler"
// 云端周一到周日的标识符
#define CLOUD_NONE @"none"
#define CLOUD_MONDAY @"mon"
#define CLOUD_TUESDAY @"tue"
#define CLOUD_WEDNESDAY @"wed"
#define CLOUD_THURSDAY @"thu"
#define CLOUD_FRIDAY @"fri"
#define CLOUD_SATURDAY @"sat"
#define CLOUD_SUNDAY @"sun"
// 云端返回数据的标识符
#define CLOUDTASK_ID @"id"
#define CLOUDTASK_DID @"did"
#define CLOUDTASK_PRODUCTKEY @"product_key"
#define CLOUDTASK_DATE @"date"
#define CLOUDTASK_TIME @"time"
#define CLOUDTASK_TASK  @"task"
#define CLOUDTASK_REPEAT @"repeat"
#define CLOUDTASK_TASK_ATTRS @"attrs"
#define CLOUDTASK_RETRY_COUNT @"retry_count"
#define CLOUDTASK_RETRY_TASK @"retry_task"
#define CLOUDTASK_RETRY_TASK_ALL @"all"
#define CLOUDTASK_RETRY_TASK_FAILED @"failed"
#define CLOUDTASK_RETRY_TASK_TIME @3

// 云端请求失败标识符
#define CLOUDFAILED_ERROR_MESSAGE @"error_message"
#define CLOUDFAILED_DETAIL_MESSAGE @"detail_message"
#define CLOUDFAILED_ERROR_CODE @"error_code"



// 云端请求头
#define CLOUD_HEADER_APPID @"X-Gizwits-Application-Id"
#define CLOUD_HEADER_USER_TOKEN @"X-Gizwits-User-token"


#import <Foundation/Foundation.h>


@interface GosNetworkTool : NSObject

@property (nonatomic, copy) NSString *oldToken;

+ (instancetype)sharedInstance;


/**
 *  创建云端定时任务
 *
 *  @param time        任务执行时间
 *  @param date        日期
 *  @param repeat 重复天数
 *  @param did         设备did
 *  @param isStart     YES，为开启任务； NO，为关闭任务
 *  @param token       用户token
 *  @param completion  完成回调
 */
- (void)sendCreateTimingRequestWithTime:(NSInteger)time andDate:(NSString *)date andRepeat:(int)repeatIndex deviceDid:(NSString *)did andIsStart:(BOOL)isStart token:(NSString *)token completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData))completion;

/**
 *  删除云端定时任务
 *
 *  @param ID         将要删除的定时任务id
 *  @param token      用户token
 *  @param completion 完成回调
 */
- (void)sendDeleteTimingRequstWithID:(NSString *)ID withToken:(NSString *)token completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData))completion;

/**
 *  查询云端定时任务
 *
 *  @param token      用户token
 *  @param completion 完成回调
 */
- (void)sendSearchTimingTaskWithToken:(NSString *)token completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData))completion;

/**
 *  删除云端所有的定时任务
 *
 *  @param token      用户token
 *  @param completion 完成回调
 */
- (void)deleteAllCoundTaskWithToken:(NSString *)token did:(NSString *)did completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage))completion;

@end
