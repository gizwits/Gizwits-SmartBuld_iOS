//
//  GosDateTimeProcess.m
//  SmartSocket
//
//  Created by danly on 16/8/4.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDateTimeProcess.h"
#import "GosNetworkTool.h"

@implementation GosDateTimeProcess

#pragma mark - 日期格式转换相关方法
+ (NSArray *)days
{
    NSDictionary *currentDate = [self getCurrentDateDic];
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *yearStr = currentDate[@"year"];
    NSString *monthStr = currentDate[@"month"];
    NSString *dayStr = currentDate[@"day"];
    
    int year = yearStr.intValue;
    int month = monthStr.intValue;
    int day = dayStr.intValue;
    
    [array addObject:[NSString stringWithFormat:@"%@.%@", monthStr, dayStr]];
    
    for (int i = 0; i < 5; ++i)
    {
        day--;
        if (day <= 0)
        {
            month--;
            if(month <= 0)
            {
                year--;
                month = 12;
            }
            
            switch (month)
            {
                case 1:
                case 3:
                case 5:
                case 7:
                case 8:
                case 10:
                case 12:
                {
                    day = 31;
                    break;
                }
                case 2:
                case 4:
                case 6:
                case 9:
                case 11:
                {
                    day = 30;
                    break;
                }
                default:
                    break;
            }
            
        }
        
        NSString *date = [NSString stringWithFormat:@"%02d.%02d", month, day];
        [array addObject:date];
    }
    
    NSMutableArray *newArr = [NSMutableArray array];
    
    for (int i = 0; i < 6; ++i)
    {
        newArr[i] = array[5-i];
    }
    
    return newArr;
}

+ (BOOL)isCurrentDay:(NSString *)date
{
    int currentDay = [self getCurrentIntDate];
    if (date.integerValue == currentDay)
    {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)getCurrentDateDic
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    NSMutableDictionary *dateDic = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString *year = [dateStr substringToIndex:4];
    NSString *month = [dateStr substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [dateStr substringWithRange:NSMakeRange(8, 2)];
    
    [dateDic setValue:year forKey:@"year"];
    [dateDic setValue:month forKey:@"month"];
    [dateDic setValue:day forKey:@"day"];
    
    return dateDic;
}

// 获取当前时区的日期
+ (NSString *)getCurrentDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    //    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Africa/Abidjan"];
    
    return [dateFormatter stringFromDate:date];
}

// 获取当前的时间 （以分钟为单位）
+ (NSInteger)getCurrentMinutes
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    
    NSString *time = [dateFormatter stringFromDate:date];
    
    NSString *hour = [time substringWithRange:NSMakeRange(0, 2)];
    NSString *minuter = [time substringWithRange:NSMakeRange(3, 2)];
    
    return hour.integerValue * 60 + minuter.integerValue;
};

// 获取时间timeValue对应的UTC时间
+ (NSString *)getUTCTime:(int)timeValue
{
    int hour = (timeValue / 60) % 24;
    int minuter = timeValue % 60;
    
    hour = (hour + [self getTimeInterval] + 24) % 24;
    
    return [NSString stringWithFormat:@"%02i:%02i", hour, minuter];
}

// 获取本时区与零时区的时间差
+ (int)getTimeInterval
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH";
    
    //零时区的时间
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Africa/Abidjan"];
    NSInteger zeroSecondsFromGMT = dateFormatter.timeZone.secondsFromGMT;
    NSLog(@"dateFormatter.timeZone = %@", dateFormatter.timeZone);
    int zeroHour = [dateFormatter stringFromDate:date].intValue;
    
//#warning test
//    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-3601];
//    NSInteger localSecondsFromGMT = dateFormatter.timeZone.secondsFromGMT;
//    NSLog(@"timeZone = %@", timeZone);
//    NSLog(@"secondsFromGMT = %zd", timeZone.secondsFromGMT);
    
    // 本地时区的时间
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    NSInteger localSecondsFromGMT = dateFormatter.timeZone.secondsFromGMT;
    NSLog(@"localtimeZone = %@", dateFormatter.timeZone);
    int localHour = [dateFormatter stringFromDate:date].intValue;
    
    if (localSecondsFromGMT - zeroSecondsFromGMT > 0)
    {
        // 东时区
        if (localHour < zeroHour)
        {
            // 东市区减去零时区时间<0才认为是东时区
            return zeroHour - (localHour + 24);
        }
        else
        {
            return zeroHour - localHour;
        }
    }
    else
    {
        //西时区
        if (zeroHour < localHour)
        {
            return (zeroHour + 24) - localHour;
        }
        else
        {
            return zeroHour - localHour;
        }
    }
}

// 根据UTC时间获取本时区时间
+ (int)getTimeFromUTCTime:(NSString *)utcTimeStr
{
    if (utcTimeStr.length != 5)
    {
        return 0;
    }
    
    int hour = [utcTimeStr substringWithRange:NSMakeRange(0, 2)].intValue - [self getTimeInterval];
    int minuter = [utcTimeStr substringWithRange:NSMakeRange(3, 2)].intValue;
    
    return (hour + 24) % 24 * 60 + minuter;
}

// 根据时间和重复天数来获取日期
+ (NSString *)getDateWithRepeat:(int)repeat WithTime:(NSInteger)time
{
    if (repeat != 0)
    {
        return @"";
    }
    
    NSInteger currentTime = [GosDateTimeProcess getCurrentMinutes];
    
    NSString *date = [GosDateTimeProcess getCurrentDate];
    NSLog(@"****************************currentDate = %@****************************", date);
    
    // 晚于当前时间，则返回今天的日期
    if (time > currentTime)
    {
        return date;
    }
    
    // 早于当前的时间，返回明天的日期
    NSString *yearMonth = [date substringToIndex:date.length - 2];
    NSString *day = [date substringWithRange:NSMakeRange(date.length - 2, 2)];

    NSString *tomorrow = [NSString stringWithFormat:@"%@%02i", yearMonth, day.intValue+1];
    
    return tomorrow;
    
}


//  根据 重复天数和 时间获取日期数值  日期 格式: yyMMMMdd
+ (int)getIntDateWithRepeat:(int)repeat WithTime:(NSInteger)time
{
    NSString *date = [self getDateWithRepeat:repeat WithTime:time];
    return [self dateWithDateStr:date];
}

// 根据当前时区的时间和日期字符串获取UTC字符串
+ (NSString *)getUTCDateWithCurrentZoneTime:(int)time andCurrentZoneDate:(NSString *)dateStr
{
    if (dateStr == nil || [dateStr isEqualToString:@""])
    {
        return @"";
    }
    
    int date = [GosDateTimeProcess dateWithDateStr:dateStr];
    NSString *dateString = [NSString stringWithFormat:@"%d",date];

    // 时区差
    NSString *UTCDate;
    
    int compareResult = [self compareCurrentToUTC:time];
    if (compareResult == 1)
    {
//        UTCDate = date - 1;
        UTCDate = [self dateStrByAddingTimeInterval:-60*60*24 withFormatterChar:@"-" andOriginalDate:dateString];
    }
    else if (compareResult == 0)
    {
        UTCDate = [self dateStrByAddingTimeInterval:0 withFormatterChar:@"-" andOriginalDate:dateString];
    }
    else if(compareResult == -1)
    {
//        UTCDate = date + 1;
        UTCDate = [self dateStrByAddingTimeInterval:60*60*24 withFormatterChar:@"-" andOriginalDate:dateString];
    }
    
    NSLog(@"utc日期 = %@", UTCDate);
    return UTCDate;
}

// 根据UTC日期 和 当前时间字符串获取当前日期
+ (int)getCurrentDateWithCurrentZoneTime:(int)time andUTCDate:(NSString *)dateStr
{
    if (dateStr == nil || [dateStr isEqualToString:@""])
    {
        return 20000101;
    }
    
    int utcDate = [GosDateTimeProcess dateWithDateStr:dateStr];
    NSString *utcDateStr = [NSString stringWithFormat:@"%d",utcDate];
    // 时区差
    NSString *currentDate;
//    int timeInterval = [GosDateTimeProcess getTimeInterval];
    
    int compareResult = [self compareCurrentToUTC:time];
    if (compareResult == 1)
    {
//        currentDate = utcDate + 1;
        currentDate = [self dateStrByAddingTimeInterval:60*60*24 withFormatterChar:@"" andOriginalDate:utcDateStr];
    }
    else if (compareResult == 0)
    {
//        currentDate = utcDate;
        currentDate = utcDateStr;
    }
    else if (compareResult == -1)
    {
//        currentDate = utcDate - 1;
        currentDate = [self dateStrByAddingTimeInterval:-60*60*24 withFormatterChar:@"" andOriginalDate:utcDateStr];
    }
  
    return currentDate.intValue;
}


// 根据周的数组获取相应的字符串值
+ (NSString *)getUTCRepeatStr:(int)repeat withTime:(int)time
{

    if (repeat == 0)
    {
        return [NSString stringWithFormat:@"%@", CLOUD_NONE];
    }
 
    int compareResult = [self compareCurrentToUTC:time];
    NSMutableString *repeatStr = [NSMutableString string];
    
    NSString *monDay = [NSString stringWithFormat:@"%@,", CLOUD_MONDAY];
    NSString *tuesDay = [NSString stringWithFormat:@"%@,", CLOUD_TUESDAY];
    NSString *wednesDay = [NSString stringWithFormat:@"%@,", CLOUD_WEDNESDAY];
    NSString *thursDay = [NSString stringWithFormat:@"%@,", CLOUD_THURSDAY];
    NSString *friDay = [NSString stringWithFormat:@"%@,", CLOUD_FRIDAY];
    NSString *saturDay = [NSString stringWithFormat:@"%@,", CLOUD_SATURDAY];
    NSString *sunDay = [NSString stringWithFormat:@"%@,", CLOUD_SUNDAY];
    
    if (repeat & WEAK_REPEAT_MONDAY)
    {
        if (compareResult == 1)
        {
            [repeatStr appendString:sunDay];
        }
        else if (compareResult == 0)
        {
            [repeatStr appendString:monDay];
        }
        else if (compareResult == -1)
        {
            [repeatStr appendString:tuesDay];
        }
    }
    if (repeat & WEAK_REPEAT_TUESDAY)
    {
        if (compareResult == 1)
        {
            [repeatStr appendString:monDay];
        }
        else if (compareResult == 0)
        {
            [repeatStr appendString:tuesDay];
        }
        else if (compareResult == -1)
        {
            [repeatStr appendString:wednesDay];
        }
    }
    if (repeat & WEAK_REPEAT_WEDNESDAY)
    {
        if (compareResult == 1)
        {
            [repeatStr appendString:tuesDay];
        }
        else if (compareResult == 0)
        {
            [repeatStr appendString:wednesDay];
        }
        else if (compareResult == -1)
        {
            [repeatStr appendString:thursDay];
        }
    }
    if (repeat & WEAK_REPEAT_THURSDAY)
    {
        if (compareResult == 1)
        {
            [repeatStr appendString:wednesDay];
        }
        else if (compareResult == 0)
        {
            [repeatStr appendString:thursDay];
        }
        else if (compareResult == -1)
        {
            [repeatStr appendString:friDay];
        }
    }
    if (repeat & WEAK_REPEAT_FRIDAY)
    {
        if (compareResult == 1)
        {
            [repeatStr appendString:thursDay];
        }
        else if (compareResult == 0)
        {
            [repeatStr appendString:friDay];
        }
        else if (compareResult == -1)
        {
            [repeatStr appendString:saturDay];
        }
    }
    if (repeat & WEAK_REPEAT_SATURDAY)
    {
        if (compareResult == 1)
        {
            [repeatStr appendString:friDay];
        }
        else if (compareResult == 0)
        {
            [repeatStr appendString:saturDay];
        }
        else if (compareResult == -1)
        {
            [repeatStr appendString:sunDay];
        }
    }
    if (repeat &WEAK_REPEAT_SUNDAY)
    {
        if (compareResult == 1)
        {
            [repeatStr appendString:saturDay];
        }
        else if (compareResult == 0)
        {
            [repeatStr appendString:sunDay];
        }
        else if (compareResult == -1)
        {
            [repeatStr appendString:monDay];
        }
    }
    
    NSUInteger length = repeatStr.length;
    if (length > 2)
    {
        // 去掉最后的逗号
        repeatStr = [NSMutableString stringWithFormat:@"%@", [repeatStr substringWithRange:NSMakeRange(0, length - 1)]];
    }
    
    return repeatStr;
}



// 根据周的字符串 获取代表的数值
+ (NSInteger)weakRepeatFromRepeatStr:(NSString *)repeatStr withTime:(int)time
{
    NSInteger weakRepeat = 0;
    
    int compareResult = [self compareCurrentToUTC:time];
    if ([repeatStr rangeOfString:[NSString stringWithFormat:@"%@", CLOUD_MONDAY]].location != NSNotFound)
    {
        if (compareResult == 1)
        {
            weakRepeat += pow(2, 1);
        }
        else if (compareResult == 0)
        {
            weakRepeat += pow(2, 0);
        }
        else if (compareResult == -1)
        {
            weakRepeat += pow(2, 6);
        }
    }
    if ([repeatStr rangeOfString:[NSString stringWithFormat:@"%@", CLOUD_TUESDAY]].location != NSNotFound)
    {
        if (compareResult == 1)
        {
            weakRepeat += pow(2, 2);
        }
        else if (compareResult == 0)
        {
            weakRepeat += pow(2, 1);
        }
        else if (compareResult == -1)
        {
            weakRepeat += pow(2, 0);
        }
    }
    if ([repeatStr rangeOfString:[NSString stringWithFormat:@"%@", CLOUD_WEDNESDAY]].location != NSNotFound)
    {
        if (compareResult == 1)
        {
            weakRepeat += pow(2, 3);
        }
        else if (compareResult == 0)
        {
            weakRepeat += pow(2, 2);
        }
        else if (compareResult == -1)
        {
            weakRepeat += pow(2, 1);
        }
    }
    if ([repeatStr rangeOfString:[NSString stringWithFormat:@"%@", CLOUD_THURSDAY]].location != NSNotFound)
    {
        if (compareResult == 1)
        {
            weakRepeat += pow(2, 4);
        }
        else if (compareResult == 0)
        {
            weakRepeat += pow(2, 3);
        }
        else if (compareResult == -1)
        {
            weakRepeat += pow(2, 2);
        }
    }
    if ([repeatStr rangeOfString:[NSString stringWithFormat:@"%@", CLOUD_FRIDAY]].location != NSNotFound)
    {
        if (compareResult == 1)
        {
            weakRepeat += pow(2, 5);
        }
        else if (compareResult == 0)
        {
            weakRepeat += pow(2, 4);
        }
        else if (compareResult == -1)
        {
            weakRepeat += pow(2, 3);
        }
    }
    if ([repeatStr rangeOfString:[NSString stringWithFormat:@"%@", CLOUD_SATURDAY]].location != NSNotFound)
    {
        if (compareResult == 1)
        {
            weakRepeat += pow(2, 6);
        }
        else if (compareResult == 0)
        {
            weakRepeat += pow(2, 5);
        }
        else if (compareResult == -1)
        {
            weakRepeat += pow(2, 4);
        }
    }
    if ([repeatStr rangeOfString:[NSString stringWithFormat:@"%@", CLOUD_SUNDAY]].location != NSNotFound)
    {
        if (compareResult == 1)
        {
            weakRepeat += pow(2, 0);
        }
        else if (compareResult == 0)
        {
            weakRepeat += pow(2, 6);
        }
        else if (compareResult == -1)
        {
            weakRepeat += pow(2, 5);
        }
    }
    
    return weakRepeat;
}

+ (int)getCurrentIntDate
{
    return [self dateWithDateStr:[self getCurrentDate]];
}

+ (int)dateWithDateStr:(NSString *)dateStr
{
    return [dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""].intValue;
}


+ (int)compareCurrentToUTC:(int)time
{
    int timeInterval = [GosDateTimeProcess getTimeInterval];
    if (timeInterval < 0)
    {
        // 东时区
        // 当前时间 + 时区差 < 0时 ： UTC = 当前日期 - 1
        float temp = time / 60.0 + timeInterval;
        if (temp < 0)
        {
            return 1;  // 1：表示 currentDate = utcDate + 1;
        }
        else
        {
            return 0;  // 0：表示 currentDate = utcDate;
        }
    }
    else
    {
        // 西时区
        // 当前时间 + 时区差 > 24  : UTC = 当前日期 + 1
        float temp = time / 60.0 + timeInterval;
        if (temp > 24)
        {
            return -1; // -1：表示 currentDate = utcDate - 1;
        }
        else
        {
            return 0;
        }
    }
}

// 传进来的date格式 yyyyMMdd
+ (NSString *)dateStrByAddingTimeInterval:(NSTimeInterval)timeInterval withFormatterChar:(NSString *)formatterChar andOriginalDate:(NSString *)originalDate
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"yyyyMMdd";
    NSDate *date = [dateformatter dateFromString:originalDate];
    date = [date dateByAddingTimeInterval:timeInterval];
    
    NSString *year = @"yyyy";
    NSString *month = @"MM";
    NSString *day = @"dd";
    
    NSString *formatter = [NSString stringWithFormat:@"%@%@%@%@%@", year, formatterChar, month, formatterChar, day];
    dateformatter.dateFormat = formatter;
    return [dateformatter stringFromDate:date];
}


@end
