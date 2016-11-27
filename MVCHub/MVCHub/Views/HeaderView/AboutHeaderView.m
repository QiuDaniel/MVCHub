//
//  AboutHeaderView.m
//  MVCHub
//
//  Created by daniel on 2016/11/24.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "AboutHeaderView.h"

@interface AboutHeaderView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation AboutHeaderView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(55, 55));
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(20);
        }];
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self.imageView.mas_bottom).offset(7);
            make.bottom.equalTo(self).offset(-7);
        }];
    }
    return self;
}


#pragma mark - Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = ({
            UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
            view.image = [UIImage imageNamed:@"mvchub_logo"];
            view;
        });
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%@ v%@ (%@)", MVC_APP_NAME, kVersion_MVCHub, kVersionBuild_MVCHub];
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = [UIColor colorWithHexString:@"0x675F5F"];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _textLabel;
}
@end
