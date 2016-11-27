//
//  NewsTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/10/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "NewsTableViewCell.h"

@interface NewsTableViewCell ()



@end

@implementation NewsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.avatarButton];
        [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.top.equalTo(self.contentView.mas_top).offset(10);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Event Response
- (void)clickAvatarButton:(UIButton *)btn {
    if([self.delegate respondsToSelector:@selector(tapAvatarButton:)]) {
        [self.delegate performSelector:@selector(tapAvatarButton:) withObject:btn];
    }
}

#pragma mark - Getter
- (UIView *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[YYLabel alloc] init];
        
        _detailLabel.top = 10;
        _detailLabel.left = 60;
        _detailLabel.width = kScreen_Width - 10 - 40 - 10 - 10;
        
        _detailLabel.displaysAsynchronously = YES;
        _detailLabel.ignoreCommonProperties = YES;
        
    }
    return _detailLabel;
}

- (UIButton *)avatarButton {
    if (!_avatarButton) {
        _avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_avatarButton addTarget:self action:@selector(clickAvatarButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarButton;
}
@end
