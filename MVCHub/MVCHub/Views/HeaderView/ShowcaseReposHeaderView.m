//
//  ShowcaseReposHeaderView.m
//  MVCHub
//
//  Created by daniel on 2016/11/18.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ShowcaseReposHeaderView.h"

@interface ShowcaseReposHeaderView ()

@property (nonatomic, strong) UIImageView *showcaseImageView;
@property (nonatomic, strong) UILabel *nameLabel, *desLabel;

@end

@implementation ShowcaseReposHeaderView

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setSize:CGSizeMake(kScreen_Width, 155)];
        [self addSubview:self.showcaseImageView];
        [self.showcaseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.mas_equalTo(70);
        }];
        
        [self.showcaseImageView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.showcaseImageView).offset(15);
            make.right.equalTo(self.showcaseImageView).offset(-15);
            make.centerY.equalTo(self.showcaseImageView);
        }];
        
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMVC_1PX_WIDTH)];
        borderView.backgroundColor = [UIColor colorWithHexString:@"0xC8C7CC"];
        [self addSubview:borderView];
        [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreen_Width, kMVC_1PX_WIDTH));
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self).offset(-2);
        }];
        
        [self addSubview:self.desLabel];
        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.bottom.equalTo(self).offset(-5);
            make.top.equalTo(self.showcaseImageView.mas_bottom).offset(5);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter
- (UIImageView *)showcaseImageView {
    if (!_showcaseImageView) {
        _showcaseImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView;
        });
    }
    return _showcaseImageView;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [UIColor colorWithHexString:@"0x675F5F"];
            label.numberOfLines = 0;
            label.font = [UIFont systemFontOfSize:15];
            label.text = @"";
            label;
        });
    }
    return _desLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:17];
            label.numberOfLines = 0;
            label.textColor = [UIColor whiteColor];
            label.text = @"";
            label;
        });
    }
    return _nameLabel;
}

- (void)setShowcase:(Showcase *)showcase {
    _showcase = showcase;
    self.nameLabel.text = showcase.name;
    self.desLabel.text = ![showcase.description_mine isEqualToString:@""] ? showcase.description_mine : @"No Description";
    [self.showcaseImageView sd_setImageWithURL:[NSURL URLWithString:showcase.image_url]];
}
@end
