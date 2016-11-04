/**
 * GosAlertView.m
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

#import "GosAlertView.h"

@interface GosAlertView ()
{
    // 提示框本身
    __strong GosAlertView *alertCtrl;
}


@property (strong, nonatomic) NSString *strMsg;
@property (strong, nonatomic) NSString *strOK;
@property (strong, nonatomic) NSString *strCancel;

@property (assign, nonatomic) id <GosAlertViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UILabel *textMessage;

//Alarm Box
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

//Fault Box
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@property (assign, nonatomic) BOOL isFaultBox;

@end

@implementation GosAlertView

- (id)initWithMessage:(NSString *)message delegate:(id <GosAlertViewDelegate>)delegate titleOK:(NSString *)titleOK titleCancel:(NSString *)titleCancel
{
    self = [super init];
    if(self)
    {
        self.strMsg = message;
        self.strOK = titleOK;
        self.strCancel = titleCancel;
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithMessage:(NSString *)message delegate:(id <GosAlertViewDelegate>)delegate titleOK:(NSString *)titleOK
{
    self = [super init];
    if(self)
    {
        self.strMsg = message;
        self.strOK = titleOK;
        self.delegate = delegate;
        self.isFaultBox = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textMessage.text = self.strMsg;
    
    if(!self.isFaultBox)
    {
        [self.btnConfirm removeFromSuperview];
        
        if (self.strOK)
            [self.btnOK setTitle:self.strOK forState:UIControlStateNormal];
        if (self.strCancel)
            [self.btnCancel setTitle:self.strCancel forState:UIControlStateNormal];
    }
    else
    {
        [self.btnOK removeFromSuperview];
        [self.btnCancel removeFromSuperview];
        
        self.imgBackground.image = [UIImage imageNamed:@"fault_tips_box.png"];
        
        if(self.strOK)
            [self.btnConfirm setTitle:self.strOK forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onConfirm:(id)sender {
    if([self.delegate respondsToSelector:@selector(GosAlertViewDidDismissButton:withButton:)])
        [self.delegate GosAlertViewDidDismissButton:self withButton:YES];
    [self hide:YES];
}

- (IBAction)onCancel:(id)sender {
    if([self.delegate respondsToSelector:@selector(GosAlertViewDidDismissButton:withButton:)])
        [self.delegate GosAlertViewDidDismissButton:self withButton:NO];
    [self hide:YES];
}

- (void)show:(BOOL)animated
{
    alertCtrl = self;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:animated];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [UIView commitAnimations];
    
    self.view.frame = [UIApplication sharedApplication].keyWindow.frame;
}

- (void)hide:(BOOL)animated
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:animated];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.view removeFromSuperview];
    [UIView commitAnimations];
    
    alertCtrl = nil;
}

@end
