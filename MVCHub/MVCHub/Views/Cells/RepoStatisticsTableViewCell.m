//
//  RepoStatisticsTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/10/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RepoStatisticsTableViewCell.h"

@interface RepoStatisticsTableViewCell ()

@end

static const NSInteger FonSize = 15;

@implementation RepoStatisticsTableViewCell

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

        [self.contentView addSubview:self.watchLabel];
        [self.watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(4);
            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.frame) / 3, 21));
        }];
        UILabel *watch = [[UILabel alloc] init];
        watch.text = @"Watch";
        watch.font = [UIFont systemFontOfSize:FonSize];
        watch.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:watch];
        [watch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.watchLabel);
            make.top.equalTo(self.watchLabel.mas_bottom);
            make.left.equalTo(self.watchLabel);
        }];
        
        [self.contentView addSubview:self.starLabel];
        [self.starLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.watchLabel.mas_right);
            make.height.equalTo(self.watchLabel);
            make.width.equalTo(self.watchLabel);
            make.top.equalTo(self.watchLabel);
            make.centerX.equalTo(self.contentView);
        }];
        
        UILabel *star = [[UILabel alloc] init];
        star.text = @"Star";
        star.font = [UIFont systemFontOfSize:FonSize];
        star.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:star];
        [star mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.watchLabel);
            make.top.equalTo(self.starLabel.mas_bottom);
            make.left.equalTo(self.starLabel);
        }];

        
        [self.contentView addSubview:self.forkLabel];
        [self.forkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.height.equalTo(self.watchLabel);
            make.width.equalTo(self.watchLabel);
            make.top.equalTo(self.watchLabel);
        }];
        UILabel *fork = [[UILabel alloc] init];
        fork.textAlignment = NSTextAlignmentCenter;
        fork.text = @"Fork";
        fork.font = [UIFont systemFontOfSize:FonSize];
        [self.contentView addSubview:fork];
        [fork mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.watchLabel);
            make.top.equalTo(self.forkLabel.mas_bottom);
            make.left.equalTo(self.forkLabel);
        }];

    }
    return self;
}

- (void)layoutSubviews {
    [self addTopBorderWithHeight:kMVC_1PX_WIDTH andColor:[UIColor colorWithHexString:@"0xC8C7CC"]];
    [self addBottomBorderWithHeight:kMVC_1PX_WIDTH andColor:[UIColor colorWithHexString:@"0xC8C7CC"]];

}
#pragma mark - Getter

- (UILabel *)watchLabel {
    if (!_watchLabel) {
        _watchLabel = [[UILabel alloc] init];
        _watchLabel.text = @"0";
        _watchLabel.font = [UIFont boldSystemFontOfSize:FonSize];
        _watchLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _watchLabel;
}

- (UILabel *)starLabel {
    if (!_starLabel) {
        _starLabel = [[UILabel alloc] init];
        _starLabel.text = @"0";
        _starLabel.font = [UIFont boldSystemFontOfSize:FonSize];
        _starLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _starLabel;
}

- (UILabel *)forkLabel {
    if (!_forkLabel) {
        _forkLabel = [[UILabel alloc] init];
        _forkLabel.text = @"0";
        _forkLabel.font = [UIFont boldSystemFontOfSize:FonSize];
        _forkLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _forkLabel;
}
@end
