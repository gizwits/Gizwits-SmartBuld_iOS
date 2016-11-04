//
//  GosDeviceScheduleTask.m
//  SmartSocket
//
//  Created by danly on 16/8/3.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceScheduleTask.h"
#import "GosDateTimeProcess.h"
#import "GosNetworkTool.h"

#define WEAK_REPEAT_MONDAY          0x01
#define WEAK_REPEAT_TUESDAY         0x02
#define WEAK_REPEAT_WEDNESDAY       0x04
#define WEAK_REPEAT_THURSDAY        0x08
#define WEAK_REPEAT_FRIDAY          0x10
#define WEAK_REPEAT_SATURDAY        0x20
#define WEAK_REPEAT_SUNDAY          0x40


@implementation GosDeviceScheduleTask

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init])
    {
        NSNumber *ID = dic[@"id"];
        self.ID = ID.intValue;
        
        self.rule_id = dic[@"rule_id"];
        self.uid = dic[@"uid"];
        self.did = dic[@"did"];
        
        NSString *task = dic[@"task"];
        self.task = task.boolValue;
        
        NSString *time = dic[@"time"];
        self.time = time.intValue;
        
        NSString *date = dic[@"date"];
        self.date = date.intValue;
        
        NSString *repeat = dic[@"repeat"];
        self.repeat = repeat.intValue;
        
        NSString *isInCloud = dic[@"isInCloud"];
        self.isInCloud = isInCloud.boolValue;
    }
    
    return self;
}

+ (NSMutableArray *)timingTasks:(NSArray *)dics
{
    NSMutableArray *tasks = [NSMutableArray array];
    
    for (NSDictionary *dic in dics)
    {
        GosDeviceScheduleTask *task = [[GosDeviceScheduleTask alloc] initWithDictionary:dic];
        [tasks addObject:task];
    }
    
    return tasks;
}

- (NSArray *)repeatIndexes
{
    NSMutableArray *indexes = [NSMutableArray array];
    int iWeekRepeat = self.repeat;
    if(iWeekRepeat & WEAK_REPEAT_MONDAY)
        [indexes addObject:@0];
    if(iWeekRepeat & WEAK_REPEAT_TUESDAY)
        [indexes addObject:@1];
    if(iWeekRepeat & WEAK_REPEAT_WEDNESDAY)
        [indexes addObject:@2];
    if(iWeekRepeat & WEAK_REPEAT_THURSDAY)
        [indexes addObject:@3];
    if(iWeekRepeat & WEAK_REPEAT_FRIDAY)
        [indexes addObject:@4];
    if(iWeekRepeat & WEAK_REPEAT_SATURDAY)
        [indexes addObject:@5];
    if(iWeekRepeat & WEAK_REPEAT_SUNDAY)
        [indexes addObject:@6];
    
    return [NSArray arrayWithArray:indexes];
}




- (NSDictionary *)getDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setValue:@(self.ID) forKey:@"id"];
    [dic setValue:self.rule_id forKey:@"rule_id"];
    [dic setValue:self.did forKey:@"did"];
    [dic setValue:[NSString stringWithFormat:@"%d", self.task] forKey:@"task"];
    [dic setValue:[NSString stringWithFormat:@"%d", self.repeat] forKey:@"repeat"];
    [dic setValue:[NSString stringWithFormat:@"%d", self.date] forKey:@"date"];
    [dic setValue:[NSString stringWithFormat:@"%d", self.time] forKey:@"time"];
    [dic setValue:self.uid forKey:@"uid"];
    [dic setValue:[NSString stringWithFormat:@"%d", self.isInCloud] forKey:@"isInCloud"];
    
    return dic;
}

- (NSArray *)dicsFromTimingTasks:(NSArray *)timingTasks
{
    NSMutableArray *dics = [NSMutableArray array];
    
    for (GosDeviceScheduleTask *task in timingTasks)
    {
        NSDictionary *dic = [task getDictionary];
        [dics addObject:dic];
    }
    
    return dics;
}

/**
 *  获取定时任务的备注时间
 *
 *  @return 备注时间
 */
- (NSString *)getTimingRemarkDate;
{
    
    NSMutableString *remark = [NSMutableString string];
    
    int everyDay = pow(2, 7) - 1;
    if (self.repeat == everyDay)
    {
        return NSLocalizedString(@"Everyday", nil);
    }
    else if (self.repeat == 0)
    {
        // 没有重复  区分 今天 明天 没有日期的情况
        int currentDate = [GosDateTimeProcess getCurrentIntDate];
        int currentTime = (int)[GosDateTimeProcess getCurrentMinutes];
        if (self.date < currentDate || (self.date == currentDate && self.time <= currentTime))
        {
            // 时间早于当前时间的情况
            return @"";
        }
        if (self.date == currentDate && self.time > currentTime)
        {
            return NSLocalizedString(@"Today", nil);
        }
        if (self.date > currentDate)
        {
            return NSLocalizedString(@"Tomorrow", nil);
        }
        
    }
    else
    {
        //重复
        if (WEAK_REPEAT_SUNDAY == (WEAK_REPEAT_SUNDAY & self.repeat))
        {
            [remark appendFormat:@"%@ ", NSLocalizedString(@"Sunday", nil)];
        }
        if (WEAK_REPEAT_MONDAY == (WEAK_REPEAT_MONDAY & self.repeat))
        {
            [remark appendFormat:@"%@ ", NSLocalizedString(@"Monday", nil)];
        }
        if (WEAK_REPEAT_TUESDAY == (WEAK_REPEAT_TUESDAY & self.repeat))
        {
            [remark appendFormat:@"%@ ", NSLocalizedString(@"Tuesday", nil)];
        }
        if (WEAK_REPEAT_WEDNESDAY == (WEAK_REPEAT_WEDNESDAY & self.repeat))
        {
            [remark appendFormat:@"%@ ", NSLocalizedString(@"Wednesday", nil)];
        }
        if (WEAK_REPEAT_THURSDAY == (WEAK_REPEAT_THURSDAY & self.repeat))
        {
            [remark appendFormat:@"%@ ", NSLocalizedString(@"Thursday", nil)];
        }
        if (WEAK_REPEAT_FRIDAY == (WEAK_REPEAT_FRIDAY & self.repeat))
        {
            [remark appendFormat:@"%@ ", NSLocalizedString(@"Friday", nil)];
        }
        if (WEAK_REPEAT_SATURDAY == (WEAK_REPEAT_SATURDAY & self.repeat))
        {
            [remark appendFormat:@"%@ ", NSLocalizedString(@"Saturday", nil)];
        }
        
        
        return remark;
    }
    
    return @"";
}


// 获取定时任务的 状态  开启/关闭
- (BOOL)getTimingTaskStatus
{
    if (!self.isInCloud)
    {
        // 不在云端的情况
        return NO;
    }
    
    // 在云端的情况
    if (self.repeat != 0)
    {
        // 重复的情况
        return YES;
    }
    
    // 仅一次的情况
    int currentDate = [GosDateTimeProcess getCurrentIntDate];
    int currentTime = (int)[GosDateTimeProcess getCurrentMinutes];
    if (self.date < currentDate || (self.date == currentDate && self.time <= currentTime))
    {
        return NO;
    }
    
    return YES;
}


@end
