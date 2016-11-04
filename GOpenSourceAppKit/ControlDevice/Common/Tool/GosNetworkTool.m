//
//  GosNetworkTool.m
//  SmartSocket
//
//  Created by danly on 16/7/13.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosNetworkTool.h"
#import "math.h"
#import "GosDateTimeProcess.h"
#import "GosDeviceControl.h"


@implementation GosNetworkTool

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

#pragma mark - http请求方法
// 创建云端定时任务
- (void)sendCreateTimingRequestWithTime:(NSInteger)time andDate:(NSString *)date andRepeat:(int)repeatIndex deviceDid:(NSString *)did andIsStart:(BOOL)isStart token:(NSString *)token completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData))completion;
{
    // 请求头
    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    [header setValue:APP_ID forKey:CLOUD_HEADER_APPID];
    [header setValue:token forKey:CLOUD_HEADER_USER_TOKEN];
    
    // 创建数据点值
    NSDictionary *data = @{DATA_ATTR_POWER_SWITCH: @(isStart)};
    
    // 请求体
    NSMutableArray *task = [NSMutableArray array];
    NSMutableDictionary *taskBody = [NSMutableDictionary dictionary];
    [taskBody setValue:did forKey:CLOUDTASK_DID];
    [taskBody setValue:PRODUCT_KEY.firstObject forKey:CLOUDTASK_PRODUCTKEY];
    [taskBody setValue:data forKey:CLOUDTASK_TASK_ATTRS];
    [task addObject:taskBody];
    
    // 当前时间
    NSString *repeat = [GosDateTimeProcess getUTCRepeatStr:repeatIndex withTime:time];
    
    date = [GosDateTimeProcess getUTCDateWithCurrentZoneTime:(int)time andCurrentZoneDate:date];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setValue:date forKey:CLOUDTASK_DATE];
    [bodyDic setValue:[GosDateTimeProcess getUTCTime:(int)time] forKey:CLOUDTASK_TIME];
    [bodyDic setValue:repeat forKey:CLOUDTASK_REPEAT];
    [bodyDic setValue:task forKey:CLOUDTASK_TASK];
    [bodyDic setValue:CLOUDTASK_RETRY_TASK_TIME forKey:CLOUDTASK_RETRY_COUNT];
    [bodyDic setValue:CLOUDTASK_RETRY_TASK_FAILED forKey:CLOUDTASK_RETRY_TASK];
    
    NSLog(@"创建定时任务 = %@", bodyDic);
    
    [self sendHttpRequest:[NSURL URLWithString:requestUrl] withHeader:header withBody:bodyDic WithMethod:@"POST" completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage,  id responseData) {
        
        if (completion)
        {
            completion(errorCode, errorMessage, detailErrorMessage, responseData);
        }
    }];
}

// 删除云端定时任务
- (void)sendDeleteTimingRequstWithID:(NSString *)ID withToken:(NSString *)token completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData))completion
{
    NSURL *url = [NSURL URLWithString:requestUrl];
    url = [url URLByAppendingPathComponent:ID];
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    [header setValue:APP_ID forKey:CLOUD_HEADER_APPID];
    [header setValue:token forKey:CLOUD_HEADER_USER_TOKEN];
    
    
    [self sendHttpRequest:url withHeader:header withBody:nil WithMethod:@"DELETE" completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {

        if (completion)
        {
            completion(errorCode, errorMessage, detailErrorMessage, responseData);
        }
        
    }];
}

// 查询云端定时任务
- (void)sendSearchTimingTaskWithToken:(NSString *)token completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData))completion
{
    NSURL *url = [NSURL URLWithString:requestUrl];
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    [header setValue:APP_ID forKey:CLOUD_HEADER_APPID];
    [header setValue:token forKey:CLOUD_HEADER_USER_TOKEN];
    
    [self sendHttpRequest:url withHeader:header withBody:nil WithMethod:@"GET" completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
        
        if (completion) {
            completion(errorCode, errorMessage, detailErrorMessage, responseData);
        }
    }];
}

// 发送http请求
- (void)sendHttpRequest:(NSURL *)url withHeader:(NSDictionary *)header withBody:(NSDictionary *)body WithMethod:(NSString *)method completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData))completion
{
    // 创建url请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    if (body != nil)
    {
        NSData *postData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:postData];
    }
    
    if (header != nil)
    {
        [request setAllHTTPHeaderFields:header];
    }
    
    [request setHTTPMethod:method];
    
    NSHTTPURLResponse *response;
    NSError *error = nil;
    NSData *reponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *reponseDic;
    if (reponseData != nil)
    {
         reponseDic = [NSJSONSerialization JSONObjectWithData:reponseData options:0 error:nil];
    }
    
    
    if (error)
    {
        // HTTP请求失败
        if (completion)
        {
            completion((int)error.code, nil, nil, nil);
        }
    }
    else
    {
        // HTTP请求成功
        if (reponseDic)
        {
            id eCode = [reponseDic valueForKey:CLOUDFAILED_ERROR_CODE];
            
            if (eCode == nil || ![eCode isKindOfClass:[NSNumber class]])
            {
                // 请求创建成功
                if (completion)
                {
                    completion(0, nil, nil, reponseDic);
                }
            }
            else
            {
                
                // 请求创建失败
                NSString *eMessage = [reponseDic valueForKey:CLOUDFAILED_ERROR_MESSAGE];
                NSDictionary *dEMessage = [reponseDic valueForKey:CLOUDFAILED_DETAIL_MESSAGE];
                
                NSNumber *errorNumber = [reponseDic valueForKey:CLOUDFAILED_ERROR_CODE];
                int errorCode = errorNumber.intValue;
                
                if (completion)
                {
                    completion(errorCode, eMessage, dEMessage, nil);
                }
            }
        }
        else
        {
            if (completion)
            {
                completion(0, nil, nil, nil);
            }
        }
    }
    
}

// 删除云端所有的定时任务
- (void)deleteAllCoundTaskWithToken:(NSString *)token did:(NSString *)did completion:(void (^)(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage))completion
{
    [self sendSearchTimingTaskWithToken:token completion:^(int errorCode, NSString *errorMessage, NSDictionary *detailErrorMessage, id responseData) {
        if (errorCode == 0)
        {
            if ([responseData isKindOfClass:[NSArray class]])
            {
                NSMutableArray *cloudTasks = [NSMutableArray array];
                for (NSDictionary *cloudTask in responseData)
                {
                    NSArray *tasks = [cloudTask valueForKey:CLOUDTASK_TASK];
                    NSDictionary *task = tasks.firstObject;
                    NSString *deviceDid = [task valueForKey:CLOUDTASK_DID];
                    if ([deviceDid isEqualToString:did])
                    {
                        [cloudTasks addObject:cloudTask];
                    }
                }
                
                for (NSDictionary *data in cloudTasks)
                {
                    NSString *ID = [data valueForKey:CLOUDTASK_ID];
                    [self sendDeleteTimingRequstWithID:ID withToken:token completion:nil];
                }
            }
            if (completion)
            {
                completion(0, nil, nil);
            }
        }
        else
        {
            if (completion)
            {
                completion(errorCode, errorMessage, detailErrorMessage);
            }
        }
    }];
}



@end
