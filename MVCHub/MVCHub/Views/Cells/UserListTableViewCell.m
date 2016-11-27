//
//  UserListTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/10/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "UserListTableViewCell.h"

@interface UserListTableViewCell ()

@end

static const NSInteger UserListTableViewCellOffset = 10;
NSInteger const UserListTableViewCellLeftImageViewWidth = 55;

@implementation UserListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UserListTableViewCellLeftImageViewWidth, UserListTableViewCellLeftImageViewWidth)];
        self.avatarImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(UserListTableViewCellLeftImageViewWidth, UserListTableViewCellLeftImageViewWidth));
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView.mas_left).offset(UserListTableViewCellOffset);
        }];
        self.loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width * 3 / 5, 21)];
        self.loginLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.loginLabel];
        [self.loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreen_Width * 3 / 5, 21));
            make.left.equalTo(self.avatarImageView.mas_right).offset(UserListTableViewCellOffset);
            make.centerY.equalTo(self.contentView).offset(-10);
        }];
        self.htmlLabel = [[UILabel alloc] init];
        self.htmlLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:self.htmlLabel];
        [self.htmlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginLabel.mas_bottom);
            make.left.equalTo(self.loginLabel.mas_left);
            make.width.mas_equalTo(self.loginLabel.width);
            make.height.mas_equalTo(self.loginLabel.height);
        }];
    }
    
    return self;
}

@end
