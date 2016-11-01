//
//  GosDateTimeProcess.h
//  SmartSocket
//
//  Created by danly on 16/8/4.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEAK_REPEAT_MONDAY          0x01
#define WEAK_REPEAT_TUESDAY         0x02
#define WEAK_REPEAT_WEDNESDAY       0x04
#define WEAK_REPEAT_THURSDAY        0x08
#define WEAK_REPEAT_FRIDAY          0x10
#define WEAK_REPEAT_SATURDAY        0x20
#define WEAK_REPEAT_SUNDAY          0x40

@interface GosDateTimeProcess : NSObject


+ (NSArray *)days;

// date的格式是:yyyyMMdd
+ (BOOL)isCurrentDay:(NSString *)date;

+ (NSDictionary *)getCurrentDateDic;

/**
 *  获取当前时区的日期
 */
+ (NSString *)getCurrentDate;

/**
 *  获取当前的时间 （以分钟为单位）
 */
+ (NSInteger)getCurrentMinutes;

/**
 *  获取时间timeValue对应的UTC时间
 */
+ (NSString *)getUTCTime:(int)timeValue;

/**
 *  获取本时区与零时区的时间差
 */
+ (int)getTimeInterval;

/**
 *  根据UTC时间获取本时区时间
 */
+ (int)getTimeFromUTCTime:(NSString *)utcTimeStr;

/**
 *  根据周数值获取相应的字符串值
 */
+ (NSString *)getUTCRepeatStr:(int)repeat withTime:(int)time;

/**
 *  根据周的字符串 获取代表的数值
 */
+ (NSInteger)weakRepeatFromRepeatStr:(NSString *)repeatStr withTime:(int)time;


/**
 *  根据时间和重复天数来获取日期
 *
 *  @param repeat 重复天数
 *  @param time   时间
 *
 *  @return 日期字符串 格式: yyyy-MM-dd
 */
+ (NSString *)getDateWithRepeat:(int)repeat WithTime:(NSInteger)time;

/**
 *  根据 重复天数和 时间获取日期数值
 *
 *  @param repeat 重复天数
 *  @param time   时间
 *
 *  @return 日期 格式: yyMMMMdd
 */
+ (int)getIntDateWithRepeat:(int)repeat WithTime:(NSInteger)time;


/**
 *  根据日期字符串获取日期数值
 *
 *  @param dateStr 日期字符串
 *
 *  @return 日期值
 */
+ (int)dateWithDateStr:(NSString *)dateStr;

/**
 *  获取当前的日期整数值
 *
 *  @return 如20160708
 */
+ (int)getCurrentIntDate;

/**
 *  根据当前时区的时间和日期字符串获取UTC字符串
 *
 *  @param time    当前时区时间
 *  @param dateStr 当前时区日期 格式:yyyy-MM-yy
 *
 *  @return UTC日期  格式:yyyy-MM-yy
 */
+ (NSString *)getUTCDateWithCurrentZoneTime:(int)time andCurrentZoneDate:(NSString *)dateStr;

/**
 *  根据UTC日期 和 当前时间字符串获取当前日期
 *
 *  @param time     当前时区时间
 *  @param dateStr UTC日期  格式:yyyy-MM-yy
 *
 *  @return 当前时区日期 格式:yyyyMMyy
 */
+ (int)getCurrentDateWithCurrentZoneTime:(int)time andUTCDate:(NSString *)dateStr;


@end
