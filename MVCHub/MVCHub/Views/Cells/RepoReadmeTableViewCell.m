//
//  RepoReadmeTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/10/25.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RepoReadmeTableViewCell.h"

@interface RepoReadmeTableViewCell () 

@property (nonatomic, strong) UILabel *readmeLabel;
@property (nonatomic, strong) UIImageView *readmeImageView;
@property (nonatomic, strong) UIView *wapperView, *readmeWapperView;

@end

static NSInteger const FontSize = 14;

@implementation RepoReadmeTableViewCell

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
        
        [self.wapperView addSubview:self.readmeWapperView];
        [self.readmeWapperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.wapperView.frame), 40));
            make.left.equalTo(self.wapperView.mas_left);
            make.right.equalTo(self.wapperView.mas_right);
            make.top.equalTo(self.wapperView.mas_top);
        }];
        
        UIView *readmeWapperViewBottomBorder = [self.readmeWapperView createViewBackedBottomBorderWithHeight:kMVC_1PX_WIDTH andColor:[UIColor colorWithHexString:@"0xC8C7CC"]];
        [self.readmeWapperView addSubview:readmeWapperViewBottomBorder];
        
        [self.wapperView addSubview:self.readmeButton];
        [self.readmeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.left.equalTo(self.wapperView.mas_left);
            make.right.equalTo(self.wapperView.mas_right);
            make.bottom.equalTo(self.wapperView.mas_bottom);
        }];
        
        UIView *readmeButtonTopBorder = [self.readmeButton createViewBackedTopBorderWithHeight:kMVC_1PX_WIDTH andColor:[UIColor colorWithHexString:@"0xC8C7CC"]];
        [self.readmeButton addSubview:readmeButtonTopBorder];
        
        [RACObserve(self, frame) subscribeNext:^(id x) {
            CGRect frame = [x CGRectValue];
            CGRect borderFrame1 = readmeWapperViewBottomBorder.frame;
            borderFrame1.size.width = frame.size.width - 30;
            readmeWapperViewBottomBorder.frame = borderFrame1;
            
            CGRect borderFrame2 = readmeButtonTopBorder.frame;
            borderFrame2.size.width = frame.size.width - 30;
            readmeButtonTopBorder.frame = borderFrame2;
        }];
        
        [self.wapperView addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.readmeWapperView.mas_bottom);
            make.left.equalTo(self.wapperView).offset(6);
            make.right.equalTo(self.wapperView).offset(-6);
            make.bottom.equalTo(self.readmeButton.mas_top);
            //make.height.mas_equalTo(21.5);
        }];
        
        [self.readmeWapperView addSubview:self.readmeImageView];
        [self.readmeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(22, 22));
            make.centerY.equalTo(self.readmeWapperView);
            make.left.equalTo(self.readmeWapperView).offset(15);
        }];
        
        [self.readmeWapperView addSubview:self.readmeLabel];
        [self.readmeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.readmeWapperView);
            make.left.equalTo(self.readmeImageView.mas_right).offset(8);
            make.top.equalTo(self.readmeImageView.mas_top);
            make.bottom.equalTo(self.readmeImageView.mas_bottom);
            make.width.mas_equalTo(92);
        }];
        
        [self.readmeWapperView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.left.equalTo(self.readmeLabel.mas_right).offset(8);
//            make.top.equalTo(self.readmeLabel);
//            make.bottom.equalTo(self.readmeLabel);
            make.centerY.equalTo(self.readmeWapperView);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.wapperView.layer.cornerRadius = 3.0;
    self.wapperView.layer.borderColor = [UIColor colorWithHexString:@"0xC8C7CC"].CGColor;
    self.wapperView.layer.borderWidth = kMVC_1PX_WIDTH;
}

#pragma mark - Getter
- (UIView *)wapperView {
    if (!_wapperView) {
        _wapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame) - 15 - 15, CGRectGetHeight(self.contentView.frame))];
    }
    return _wapperView;
}

- (UIView *)readmeWapperView {
    if (!_readmeWapperView) {
        _readmeWapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_wapperView.frame), 40)];
    }
    return _readmeWapperView;
}

- (UIButton *)readmeButton {
    if (!_readmeButton) {
        _readmeButton = [[UIButton alloc] init];
        [_readmeButton setTitle:@"View all of README.md" forState:UIControlStateNormal];
        _readmeButton.tintColor = [UIColor colorWithHexString:@"0x4183C4"];
        [_readmeButton setTitleColor:[UIColor colorWithHexString:@"0x4183C4"] forState:UIControlStateNormal];
        [_readmeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:FontSize]];
        
    }
    return _readmeButton;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.userInteractionEnabled = NO;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}

- (UILabel *)readmeLabel {
    if (!_readmeLabel) {
        _readmeLabel = [[UILabel alloc] init];
        _readmeLabel.text = @"README.md";
        _readmeLabel.font = [UIFont boldSystemFontOfSize:FontSize];
    }
    return _readmeLabel;
}

- (UIImageView *)readmeImageView {
    if (!_readmeImageView) {
        _readmeImageView = [[UIImageView alloc] init];
        _readmeImageView.image = [UIImage octicon_imageWithIcon:@"Book"
                                                backgroundColor:[UIColor clearColor]
                                                      iconColor:[UIColor darkGrayColor]
                                                      iconScale:1
                                                        andSize:CGSizeMake(22, 22)];
        
    }
    return _readmeImageView;
}

- (UIView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    return _activityIndicatorView;
}

@end
