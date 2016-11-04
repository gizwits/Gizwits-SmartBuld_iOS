//
//  UIColor+HexCodes.h
//  HSVColorPicker
//
//  Created by Nicholas Hart on 10/14/14.
//  Copyright (c) 2014 Nicholas Hart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexCodes)

/** Helper method to return a hex format, eg: #112233
 @return a string containing the hex format
 */
- (NSString *)formatHexCode;

/**
 *  判断三色值是否在色温的范围内
 *
 *  @param red   红色值
 *  @param green 绿色值
 *  @param blue  蓝色值
 *
 *  @return 
 */
- (BOOL)getColor:(CGFloat *)red withGreen:(CGFloat *)green withBlue:(CGFloat *)blue;

/**
 *  获取颜色的三色值 范围（0~255）
 *
 *  @param red   红色值
 *  @param green 绿色值
 *  @param blue  蓝色值
 */
- (void)getColorWithRed:(CGFloat *)red withGreen:(CGFloat *)green withBlue:(CGFloat *)blue;

@end
