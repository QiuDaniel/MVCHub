//
//  RepoViewCodeTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/10/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RepoViewCodeTableViewCell.h"

@interface RepoViewCodeTableViewCell ()

@property (nonatomic, strong) UIView *wapperView, *separatorView, *separatorViewTopBorder;

@end

static NSInteger const FontSize = 14;

@implementation RepoViewCodeTableViewCell

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
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.contentView addSubview:self.wapperView];
        [self.wapperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 15, 0, 15));
        }];
        [self.wapperView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.wapperView.mas_left).offset(15);
            make.right.equalTo(self.wapperView.mas_right).offset(15);
            make.height.mas_equalTo(37);
            make.top.equalTo(self.wapperView.mas_top);
        }];
        
        [self.wapperView addSubview:self.separatorView];
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.wapperView.mas_left);
            make.right.equalTo(self.wapperView.mas_right);
            make.top.equalTo(self.timeLabel.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        [self.wapperView addSubview:self.viewCodeButton];
        [self.viewCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.wapperView.mas_right);
            make.left.equalTo(self.wapperView.mas_left);
            make.bottom.equalTo(self.wapperView.mas_bottom);
            make.height.mas_equalTo(40);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    self.wapperView.layer.borderColor = [UIColor colorWithHexString:@"0xC8C7CC"].CGColor;
    self.wapperView.layer.borderWidth = kMVC_1PX_WIDTH;
    self.wapperView.layer.cornerRadius = 3.0;
    
    [self.separatorViewTopBorder removeFromSuperview];
    self.separatorViewTopBorder = [self.separatorView createViewBackedTopBorderWithHeight:kMVC_1PX_WIDTH andColor:[UIColor colorWithHexString:@"0xC8C7CC"]];
    [self.separatorView addSubview:self.separatorViewTopBorder];
}

#pragma mark - Getter;

- (UIView *)wapperView {
    if (!_wapperView) {
        _wapperView = [[UIView alloc] init];
    }
    return _wapperView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text = @"updated 2 weeks ago";
        _timeLabel.font = [UIFont systemFontOfSize:FontSize];
    }
    return _timeLabel;
}

- (UIButton *)viewCodeButton {
    if (!_viewCodeButton) {
        _viewCodeButton = [[UIButton alloc] init];
        [_viewCodeButton setTitle:@"View Code" forState:UIControlStateNormal];
        _viewCodeButton.tintColor = [UIColor colorWithHexString:@"0x4183C4"];
        [_viewCodeButton setTitleColor:[UIColor colorWithHexString:@"0x4183C4"] forState:UIControlStateNormal];
        [_viewCodeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:FontSize]];
    }
    return _viewCodeButton;
}

@end
