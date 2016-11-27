//
//  ReposTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/11/8.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ReposTableViewCell.h"

@interface ReposTableViewCell ()

@property (nonatomic, strong) UIImageView *starIconImageView, *forkIconImageView;

@end

@implementation ReposTableViewCell

#pragma mark - Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(8);
            make.size.mas_equalTo(CGSizeMake(22, 22));
            make.top.equalTo(self.contentView).offset(8);
        }];
        
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(8);
            make.left.equalTo(self.iconImageView.mas_right).offset(8);
            make.right.equalTo(self.contentView).offset(-8);
            make.height.mas_equalTo(20.5);
            make.centerY.equalTo(self.iconImageView);
        }];
        
        [self.contentView addSubview:self.desLabel];
        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-8);
            make.leading.equalTo(self.nameLabel.mas_leading);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        }];
        
        [self.contentView addSubview:self.languageLabel];
        [self.languageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.desLabel.mas_bottom).offset(5);
            make.leading.equalTo(self.desLabel.mas_leading);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo(68);
        }];
        
        [self.contentView addSubview:self.starIconImageView];
        [self.starIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.left.equalTo(self.languageLabel.mas_right).offset(10);
            make.centerY.equalTo(self.languageLabel);
        }];
        
        [self.contentView addSubview:self.starCountLabel];
        [self.starCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.starIconImageView.mas_right).offset(4);
            make.height.mas_equalTo(15);
            make.centerY.equalTo(self.languageLabel);
            make.width.mas_equalTo(40);
        }];
        
        [self.contentView addSubview:self.forkIconImageView];
        [self.forkIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.desLabel.mas_bottom).offset(5);
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.left.equalTo(self.starCountLabel.mas_right).offset(10);
            make.centerY.equalTo(self.languageLabel);
        }];
        
        [self.contentView addSubview:self.forkCountLabel];
        [self.forkCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(15);
            make.left.equalTo(self.forkIconImageView.mas_right).offset(4);
            make.centerY.equalTo(self.languageLabel);
        }];
        
        [self.contentView addSubview:self.updateTimeLabel];
        [self.updateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-8);
            make.left.equalTo(self.forkCountLabel.mas_right).offset(10);
            make.centerY.equalTo(self.languageLabel);
            make.height.mas_equalTo(14.5);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:17.0];
        _nameLabel.text = @"MVCHub";
    }
    return _nameLabel;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.font = [UIFont systemFontOfSize:15.0];
        _desLabel.text = @"GitHub App based on MVC model";
        _desLabel.numberOfLines = 3;
    }
    return _desLabel;
}

- (UILabel *)languageLabel {
    if (!_languageLabel) {
        _languageLabel = [[UILabel alloc] init];
        _languageLabel.font = [UIFont systemFontOfSize:12.0];
        _languageLabel.text = @"Objectivc-C";
    }
    return _languageLabel;
}

- (UIImageView *)starIconImageView {
    if (!_starIconImageView) {
        _starIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _starIconImageView.image = [UIImage octicon_imageWithIcon:@"Star"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor darkGrayColor]
                                                        iconScale:1
                                                          andSize:_starIconImageView.frame.size];
    }
    return _starIconImageView;
}

- (UILabel *)starCountLabel {
    if (!_starCountLabel) {
        _starCountLabel = [[UILabel alloc] init];
        _starCountLabel.font = [UIFont systemFontOfSize:12.0];
        _starCountLabel.text = @"0";
    }
    return _starCountLabel;
}

- (UIImageView *)forkIconImageView {
    if (!_forkIconImageView) {
        _forkIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _forkIconImageView.image = [UIImage octicon_imageWithIcon:@"GitBranch"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor darkGrayColor]
                                                        iconScale:1
                                                          andSize:_forkIconImageView.frame.size];
    }
    return _forkIconImageView;
}

- (UILabel *)forkCountLabel {
    if (!_forkCountLabel) {
        _forkCountLabel = [[UILabel alloc] init];
        _forkCountLabel.text = @"1";
        _forkCountLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _forkCountLabel;
}

- (UILabel *)updateTimeLabel {
    if (!_updateTimeLabel) {
        _updateTimeLabel = [[UILabel alloc] init];
        _updateTimeLabel.text = @"";
        _updateTimeLabel.font = [UIFont systemFontOfSize:12.0];
        _updateTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _updateTimeLabel;
}
@end
