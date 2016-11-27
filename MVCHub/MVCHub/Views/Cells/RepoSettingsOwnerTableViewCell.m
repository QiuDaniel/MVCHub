//
//  RepoSettingsOwnerTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/11/6.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RepoSettingsOwnerTableViewCell.h"
#import "TGRImageZoomAnimationController.h"
#import "TGRImageViewController.h"

@interface RepoSettingsOwnerTableViewCell () <UIViewControllerTransitioningDelegate>

@end

@implementation RepoSettingsOwnerTableViewCell

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
        [self.contentView addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(65, 65));
            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.centerY.equalTo(self.contentView);
            
        }];
        
        [self.contentView addSubview:self.topLabel];
        [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView).offset(-11.5);
            make.right.equalTo(self.contentView).offset(-20);
            make.left.equalTo(self.avatarImageView.mas_right).offset(10);
        }];
        
        [self.contentView addSubview:self.bottomLabel];
        [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView).offset(11.5);
            make.right.equalTo(self.contentView).offset(-20);
            make.left.equalTo(self.avatarImageView.mas_right).offset(10);
        }];
        
        [self.avatarImageView addSubview:self.avatarButton];
        [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.avatarImageView);
        }];
        
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarImageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarImageView];
    }
    return nil;
}


#pragma mark - Response Event
- (void)clickAvatarButton {
    MVCSharedAppDelegate.window.backgroundColor = [UIColor blackColor];
    
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:self.avatarImageView.image];
    viewController.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    viewController.transitioningDelegate = self;
    
    [MVCSharedAppDelegate.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Getter
- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.backgroundColor = [UIColor colorWithHexString:@"0xEDEDED"];
        _avatarImageView.layer.cornerRadius = 10.0;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.userInteractionEnabled = YES;
    }
    return _avatarImageView;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
    }
    return _topLabel;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
    }
    return _bottomLabel;
}

- (UIButton *)avatarButton {
    if (!_avatarButton) {
        _avatarButton = [[UIButton alloc] init];
        [_avatarButton addTarget:self action:@selector(clickAvatarButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarButton;
}
@end
