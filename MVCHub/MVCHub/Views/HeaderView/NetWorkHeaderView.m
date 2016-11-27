//
//  NetWorkHeaderView.m
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "NetWorkHeaderView.h"

@interface NetWorkHeaderView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end


@implementation NetWorkHeaderView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xfed6d7"];
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(29, 29));
            make.left.equalTo(self.mas_left).offset(15);
            make.centerY.equalTo(self);
        }];
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).offset(8);
            make.right.equalTo(self.mas_right).offset(-8);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        _imageView.image = [UIImage octicon_imageWithIcon:@"IssueOpened"
                                          backgroundColor:[UIColor clearColor]
                                                iconColor:[UIColor colorWithHexString:@"0xF1494D"] iconScale:1
                                                  andSize:CGSizeMake(29, 29)];
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.text = @"NetWork unavailable, check network!";
    }
    return _label;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
