//
//  IoTVersion.m
//  gokit
//
//  Created by Zono on 15/12/24.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "IoTVersion.h"

@interface IoTVersion () <UIAlertViewDelegate> {
    BOOL isUpdateReuqired;
    NSDictionary *dictUpdateInfo;
    
    UIAlertView *_alertView;
}

@property (weak, nonatomic) IBOutlet UILabel *textVersion;
@property (weak, nonatomic) IBOutlet UILabel *textSDKVersion;

@end

@implementation IoTVersion

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"版本信息";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    
    self.textVersion.text = [self.textVersion.text stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    self.textSDKVersion.text = [self.textSDKVersion.text stringByAppendingString:[XPGWifiSDK getVersion]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
