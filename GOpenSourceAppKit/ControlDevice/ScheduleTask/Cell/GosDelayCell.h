//
//  GosDelayCell.h
//  SmartSocket
//
//  Created by danly on 16/8/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GosDelayCell;
@protocol GosSchedullCloseCellDelegate <NSObject>

- (void)schedullCloseCell:(GosDelayCell *)cell switchValueChange:(UISwitch *)schedullSwitch;

@end

@interface GosDelayCell : UITableViewCell

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, weak) id<GosSchedullCloseCellDelegate> delegate;


@end
