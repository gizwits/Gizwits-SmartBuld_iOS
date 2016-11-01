//
//  GosRepeatSelectCell.m
//  SmartSocket
//
//  Created by danly on 16/8/2.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GosDeviceRepeatSelectCell.h"

@interface GosDeviceRepeatSelectCell ()

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UIButton *selectedBtn;

@end

@implementation GosDeviceRepeatSelectCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
//        [self.selectedBtn setBackgroundColor:[UIColor blueColor]];
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"repeat_btn_select.png"] forState:UIControlStateSelected];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:16]];
    
    self.selectedBtn.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:22]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:18]];
}

- (void)setSelect:(BOOL)select
{
    _select = select;
    self.selectedBtn.selected = select;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        UILabel *label = [[UILabel alloc] init];
        [self.contentView addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UIButton *)selectedBtn
{
    if (!_selectedBtn)
    {
        UIButton *btn = [[UIButton alloc] init];
        [self.contentView addSubview:btn];
        _selectedBtn = btn;
    }
    return _selectedBtn;
}



@end
