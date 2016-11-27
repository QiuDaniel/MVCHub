//
//  DoubleTitleView.m
//  MVCHub
//
//  Created by daniel on 2016/11/3.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DoubleTitleView.h"

@implementation DoubleTitleView
#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
//        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self);
//            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2));
//            make.left.equalTo(self);
//            make.right.equalTo(self);
//        }];
        [self addSubview:self.subtitleLabel];
//        [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(self);
//            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2));
//            make.left.equalTo(self);
//            make.right.equalTo(self);
//        }];
        @weakify(self)
        RACSignal *titleLabelSignal = [RACObserve(self.titleLabel, text) doNext:^(id x) {
            @strongify(self)
            [self.titleLabel sizeToFit];
        }];
        
        RACSignal *subtitleLabelSignal = [RACObserve(self.subtitleLabel, text) doNext:^(id x) {
            @strongify(self)
            [self.subtitleLabel sizeToFit];
        }];
        
        [[RACSignal combineLatest:@[ titleLabelSignal, subtitleLabelSignal ]] subscribeNext:^(RACTuple *tuple) {
            @strongify(self)
            self.frame = CGRectMake(0, 0, MAX(CGRectGetWidth(self.titleLabel.frame), CGRectGetWidth(self.subtitleLabel.frame)), 44);
        }];

        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect titleLabelFrame = self.titleLabel.frame;
    titleLabelFrame.size.width = MIN(CGRectGetWidth(self.titleLabel.frame), CGRectGetWidth(self.frame));
    titleLabelFrame.origin.x = CGRectGetWidth(self.frame) / 2 - CGRectGetWidth(titleLabelFrame) / 2;
    titleLabelFrame.origin.y = 4;
    self.titleLabel.frame = titleLabelFrame;
    
    CGRect subtitleLabelFrame = self.subtitleLabel.frame;
    subtitleLabelFrame.size.width = MIN(CGRectGetWidth(self.subtitleLabel.frame), CGRectGetWidth(self.frame));
    subtitleLabelFrame.origin.x = CGRectGetWidth(self.frame) / 2 - CGRectGetWidth(subtitleLabelFrame) / 2;
    subtitleLabelFrame.origin.y = CGRectGetHeight(self.frame) - 4 - CGRectGetHeight(self.subtitleLabel.frame);
    self.subtitleLabel.frame = subtitleLabelFrame;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:15];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = [UIColor whiteColor];
    }
    return _subtitleLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
