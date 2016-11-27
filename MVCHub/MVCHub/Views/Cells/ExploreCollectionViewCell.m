//
//  ExploreCollectionViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/11/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ExploreCollectionViewCell.h"

@implementation ExploreCollectionViewCell

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70, 70));
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(5);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.numberOfLines = 2;
        _nameLabel.text = @"";
    }
    return _nameLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _avatarImageView.image = [[UIColor colorWithHexString:@"0xEDEDED"] color2ImageSized:_avatarImageView.frame.size];
        _avatarImageView.layer.cornerRadius = 15;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarImageView;
}
@end
