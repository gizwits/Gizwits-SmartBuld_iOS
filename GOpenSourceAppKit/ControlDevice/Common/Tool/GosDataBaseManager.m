//
//  GosDataBaseManager.m
//  DataBaseTest
//
//  Created by danly on 16/8/3.
//  Copyright © 2016年 gizwits. All rights reserved.
//

#import "GosDataBaseManager.h"
#import "FMDB.h"
#import "GosDeviceScheduleTask.h"

#define DBTableName @"TimingTask"

@interface GosDataBaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) NSArray *colNames;

@end

@implementation GosDataBaseManager

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        // 创建数据库
        [(GosDataBaseManager *)instance createTable];
    });
    
    return instance;
}

/**
 *  添加新数据到数据库
 *
 *  @param data       新数据
 */
- (void)addData:(NSDictionary *)data
{
    NSMutableString *sql = [NSMutableString string];
    
    [sql appendString:[NSString stringWithFormat:@"INSERT INTO %@ (", DBTableName]];
    for (NSString *colName in self.colNames)
    {
        [sql appendString:colName];
        [sql appendString:@","];
    }
    
    // 去除逗号
    sql = [NSMutableString stringWithFormat:@"%@", [sql substringToIndex:(sql.length - 1)]];
    
    [sql appendString:@") VALUES ("];
    
    for (NSString *colName in self.colNames)
    {
        [sql appendFormat:@"\"%@\",", data[colName]];
    }
    
    sql = [NSMutableString stringWithFormat:@"%@", [sql substringToIndex:(sql.length - 1)]];
    [sql appendFormat:@");"];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
    
        if ([db executeUpdate:sql])
        {
            NSLog(@"添加数据到数据库成功");
            NSLog(@"查询完成所在线程: %@", [NSThread currentThread]);
        }
        else
        {
            NSLog(@"添加数据到数据库失败");
            NSLog(@"查询完成所在线程: %@", [NSThread currentThread]);
        }
    }];
    
}

/**
 *  根据条件删除相应的数据库数据
 *
 *  @param conditions 条件字典： key：数据库字段名  value：字段值
 */
- (void)deleteDataWithConditions:(NSDictionary *)conditions
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ ", DBTableName];
    
    if (conditions.count > 0)
    {
        [sql appendFormat:@"WHERE "];
        [conditions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    
            [sql appendFormat:@"%@ = \"%@\" ", key, obj];
            [sql appendFormat:@"AND "];
        }];
        
        sql = [NSMutableString stringWithFormat:@"%@",[sql substringToIndex:sql.length - 4]];
        [sql appendString:@";"];
    }

    NSLog(@"删除的sql语句: %@", sql);
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:sql])
        {
            NSLog(@"****************************删除数据成功****************************");
        }
        else
        {
            NSLog(@"****************************删除数据失败****************************");
        }
    }];
}

/**
 *  根据查询条件查询数据库数据
 *
 *  @param conditions 查询字典： key：数据库字段名  value：字段值
 *  @param completion 完成回调，回调获取到的数据datas
 */
- (void)searchDatasWithConditions:(NSDictionary *)conditions completion:(void (^)(NSArray *datas))completion
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ", DBTableName];
    
    if (conditions.count > 0)
    {
        [sql appendFormat:@"WHERE "];
        [conditions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isEqualToString:Id])
            {
                [sql appendFormat:@"%@ = %@ ", key, obj];
                [sql appendFormat:@"AND "];
            }
            else
            {
                [sql appendFormat:@"%@ = \"%@\" ", key, obj];
                [sql appendFormat:@"AND "];
            }
        }];
        
        sql = [NSMutableString stringWithFormat:@"%@",[sql substringToIndex:sql.length - 4]];
    }
    
    [sql appendFormat:@" ORDER BY %@ DESC", Id];
    
    
    NSMutableArray *datas = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resuleSet = [db executeQuery:sql];
       
        NSLog(@"%@", sql);
        NSLog(@"resuleSet = %@", resuleSet);
        NSLog(@"查询数据完成");
        
        while ([resuleSet next])
        {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:self.colNames.count];
            
            int ID = [resuleSet intForColumn:@"id"];
            [data setValue:@(ID) forKey:@"id"];
            for (NSString *colName in self.colNames)
            {
                NSString *colValue = [resuleSet stringForColumn:colName];
                [data setValue:colValue forKey:colName];
            }
            [datas addObject:data];
        }
        
        if (completion)
        {
            completion([GosDeviceScheduleTask timingTasks:datas]);
        }
    }];
}

/**
 *  根据条件更新相应的数据
 *
 *  @param condictions 条件字典： key：数据库字段名  value：字段值
 *  @param data        新数据
 */
- (void)updataWithConditions:(NSDictionary *)condictions withNewData:(NSDictionary *)data
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", DBTableName];
    [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        // 设置主键不能更新
        if (![key isEqualToString:Id])
        {
            [sql appendFormat:@"%@ = \"%@\",", key, obj];
        }
    }];
    
    sql = [NSMutableString stringWithFormat:@"%@", [sql substringToIndex:sql.length - 1]];
    
    if (condictions > 0)
    {
        [sql appendString:@" WHERE "];
        
        [condictions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            [sql appendFormat:@"%@ = \"%@\" AND ", key, obj];
        }];
        
        sql = [NSMutableString stringWithFormat:@"%@", [sql substringToIndex:sql.length - 4]];
    }
    
    NSLog(@"****************************更新sql语句****************************");
    NSLog(@"%@", sql);
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:sql])
        {
            NSLog(@"更新成功");
        }
        else
        {
            NSLog(@"更新失败");
        }
    }];
}

 // 创建一个数据库表
- (void)createTable
{
    // 创建数据库
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        self.colNames = @[Rule_ID, Uid, Did, Task, Time, Date, Repeat, IsInCloud];
        [self createDataBase];
    });
    
    
    NSMutableString *sql = [NSMutableString string];

    [sql appendString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", DBTableName]];
    [sql appendString:@"id INTEGER PRIMARY KEY AUTOINCREMENT"];
    for (NSString *colName in self.colNames)
    {
        [sql appendString:@","];
        [sql appendString:[NSString stringWithFormat:@"%@ TEXT", colName]];
    }
    [sql appendString:@");"];
    
    NSLog(@"创建表的SQL:");
    NSLog(@"%@", sql);
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:sql])
        {
            NSLog(@"****************************创建表成功****************************");
        }
        else
        {
            NSLog(@"****************************创建表失败****************************");
        }
    }];
}

// 创建数据库
- (void)createDataBase
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"TimingTask.db"];
    
    NSLog(@"****************************%@****************************", dbPath);
    
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
}



@end
