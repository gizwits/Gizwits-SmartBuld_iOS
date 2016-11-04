//
//  GosDataBaseManager.h
//  DataBaseTest
//
//  Created by danly on 16/8/3.
//  Copyright © 2016年 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

// 数据库字段宏
#define Id @"id"
#define Rule_ID @"rule_id"
#define Uid @"uid"
#define Did @"did"
#define Task @"task"
#define Time @"time"
#define Date @"date"
#define Repeat @"repeat"
#define IsInCloud @"isInCloud"

@interface GosDataBaseManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  创建数据库表
 */
- (void)createTable;

/**
 *  根据查询条件查询数据库数据
 *
 *  @param conditions 查询字典： key：数据库字段名  value：字段值
 *  @param completion 完成回调，回调获取到的数据datas
 */
- (void)searchDatasWithConditions:(NSDictionary *)conditions completion:(void (^)(NSArray *datas))completion;

/**
 *  添加新数据到数据库
 *
 *  @param data       新数据
 */
- (void)addData:(NSDictionary *)data;

/**
 *  根据条件删除相应的数据库数据
 *
 *  @param conditions 条件字典： key：数据库字段名  value：字段值
 */
- (void)deleteDataWithConditions:(NSDictionary *)conditions;

/**
 *  根据条件更新相应的数据
 *
 *  @param condictions 条件字典： key：数据库字段名  value：字段值
 *  @param data        新数据
 */
- (void)updataWithConditions:(NSDictionary *)condictions withNewData:(NSDictionary *)data;

@end
