//
//  UIColor+HexCodes.m
//  HSVColorPicker
//
//  Created by Nicholas Hart on 10/14/14.
//  Copyright (c) 2014 Nicholas Hart. All rights reserved.
//

#import "UIColor+HexCodes.h"

#define FLOAT_TO_UINT16(value) ((uint16_t)roundf(value * 255.0))

@implementation UIColor (HexCodes)

- (NSString *)formatHexCode {
    CGFloat red, green, blue, alpha;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        return [NSString stringWithFormat:@"#%02X%02X%02X", FLOAT_TO_UINT16(red), FLOAT_TO_UINT16(green), FLOAT_TO_UINT16(blue)];
    }
    return nil;
}

- (BOOL)getColor:(CGFloat *)red withGreen:(CGFloat *)green withBlue:(CGFloat *)blue
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    unsigned int redTemp = components[0] * 255;
    unsigned int greenTemp = components[1] * 255;
    unsigned int blueTemp = components[2] * 255;
    
    if (redTemp >= 227 && redTemp <= 255 && greenTemp >= 141 && greenTemp <= 233 && blueTemp >= 11 && blueTemp <= 255)
    {
        *red = redTemp;
        *green = greenTemp;
        *blue = blueTemp;
        
        return YES;
    }
    return NO;
}

- (void)getColorWithRed:(CGFloat *)red withGreen:(CGFloat *)green withBlue:(CGFloat *)blue
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    *red = components[0] * 255;
    *green = components[1] * 255;
    *blue = components[2] * 255;
}

@end
