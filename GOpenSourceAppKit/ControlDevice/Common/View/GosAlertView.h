/**
 * GosAlertView.h
 *
 * Copyright (c) 2014~2015 Xtreme Programming Group, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

@class GosAlertView;

/**
 *  代理
 */
@protocol GosAlertViewDelegate <NSObject>
@optional

/**
 *  点击提示框按钮时 调用的代理方法
 *
 *  @param alertView 提示框对象
 *  @param isConfirm 按钮标识   YES: 表示确定按钮  NO: 表示取消按钮
 */
- (void)GosAlertViewDidDismissButton:(GosAlertView *)alertView withButton:(BOOL)isConfirm;

@end




/**
 *  带按钮的提示框类
 */
@interface GosAlertView : UIViewController

@property (assign, nonatomic) NSInteger tag;

/**
 *  带两个按钮的提示框
 *
 *  @param message     提示框消息
 *  @param delegate    代理
 *  @param titleOK     确定按钮
 *  @param titleCancel 取消按钮
 *
 */
- (id)initWithMessage:(NSString *)message delegate:(id <GosAlertViewDelegate>)delegate titleOK:(NSString *)titleOK titleCancel:(NSString *)titleCancel;

/**
 *  带一个按钮的提示框
 *
 *  @param message  提示框消息
 *  @param delegate 代理
 *  @param titleOK  确定按钮
 *
 */
- (id)initWithMessage:(NSString *)message delegate:(id <GosAlertViewDelegate>)delegate titleOK:(NSString *)titleOK;

/**
 *  显示提示框
 */
- (void)show:(BOOL)animated;

/**
 *  隐藏提示框
 */
- (void)hide:(BOOL)animated;

@end
