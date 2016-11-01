//
//  GosTimeSelectCell.h
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    GosTimeSelectTypeDelay = 0,  //延时
    GosTimeSelectTypeSchedule = 1   //定时
}GosTimeSelectType;

@class GosTimeSelectCell;
@protocol GosTimeSelectCellDelegate <NSObject>

- (void)timerScheduleCell:(GosTimeSelectCell *)cell didSelectedMinutes:(NSInteger)minutes;

@end

@interface GosTimeSelectCell : UITableViewCell

- (instancetype)initWithTimerScheduleType:(GosTimeSelectType)type;

@property (nonatomic, assign) NSInteger minutes;
@property (nonatomic, weak) id<GosTimeSelectCellDelegate> delegate;

@end
