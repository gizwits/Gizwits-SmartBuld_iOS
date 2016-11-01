//
//  GosRepeatSelectCell.h
//  SmartSocket
//
//  Created by danly on 16/8/2.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GosDeviceRepeatSelectCell : UITableViewCell

@property (nonatomic, assign, getter=isSelect) BOOL select;
@property (nonatomic, copy) NSString *title;

@end
