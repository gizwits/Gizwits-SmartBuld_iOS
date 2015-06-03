/**
 * IoTAccountManager.m
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

#import "IoTAccountManager.h"
#import "IoTChangePassword.h"
#import <IoTProcessModel/IoTProcessModel.h>
#import "IoTAlertView.h"

@interface IoTAccountManager () <IoTAlertViewDelegate>
{
    NSArray *subItems;
}

@end

@implementation IoTAccountManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"用户管理";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    subItems = @[@"用户名称", @"修改密码"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)onLogout:(id)sender {
    [[[IoTAlertView alloc] initWithMessage:@"确定要注销，返回登陆界面吗？" delegate:self titleOK:@"返回" titleCancel:@"注销"] show:YES];
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return subItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentifier = @"accountManagerIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }
    
    UIColor *textColor = [UIColor darkGrayColor];
    
    cell.textLabel.text = subItems[indexPath.row];
    cell.textLabel.textColor = textColor;
    if(indexPath.row == 1)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        label.textColor = textColor;
        cell.accessoryView = label;
        label.text = [IoTProcessModel sharedModel].currentUser;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1)
        return YES;
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IoTChangePassword *changePasswordCtrl = [[IoTChangePassword alloc] init];
    [self.navigationController pushViewController:changePasswordCtrl animated:YES];
}

#pragma mark - alertView
- (void)IoTAlertViewDidDismissButton:(IoTAlertView *)alertView withButton:(BOOL)isConfirm
{
    if(!isConfirm)
    {
        [[IoTProcessModel sharedModel] logout];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
