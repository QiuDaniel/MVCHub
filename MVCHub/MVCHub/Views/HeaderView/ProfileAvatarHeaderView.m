//
//  ProfileAvatarHeaderView.m
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ProfileAvatarHeaderView.h"
#import "TGRImageZoomAnimationController.h"
#import "TGRImageViewController.h"
#import "UserListViewController.h"
#import "PublicReposViewController.h"

#define ProfileAvatarHeaderViewSpace 59
#define ProfileAvatarHeaderViewContentOffsetRadix 40.0f

@interface ProfileAvatarHeaderView () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIView *overView;
@property (nonatomic, strong) UILabel *nameLabel, *followersLabel, *repositoriesLabel, *followingLabel;
@property (nonatomic, strong) UIButton *avatarButton, *followersButton, *repositoriesButton, *followingButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) GPUImageGaussianBlurFilter *gaussianBlurFilter;
@property (nonatomic, strong) UIImageView *coverImageView, *bluredCoverImageView;
@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation ProfileAvatarHeaderView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame user:(OCTUser *)user{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _user = user;
        //DebugLog(@"Profile--user======>%@",user);
        self.overView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.overView];
        [self.overView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.avatarImage = [UIImage imageNamed:@"default-avatar"];
        MVCWeakSelf
        [[SDWebImageManager sharedManager] downloadImageWithURL:_user.avatarURL
                                                        options:SDWebImageRefreshCached
                                                       progress:nil
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                          if (image && finished) {
                                                              __weakSelf.avatarImage = image;
                                                          }
                                                      }];
        
        self.avatarButton = ({
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width / 5, kScreen_Width / 5)];
            btn.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.imageView.layer.borderWidth = 2.0f;
            btn.imageView.layer.cornerRadius = CGRectGetWidth(btn.frame) / 2;
            btn.imageView.backgroundColor = [UIColor colorWithHexString:@"0xebe9e5"];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [btn setImage:self.avatarImage forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickAvatarBtn) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self.overView addSubview:self.avatarButton];
        [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreen_Width / 5, kScreen_Width / 5));
            make.centerX.equalTo(self.overView);
            make.centerY.equalTo(self.overView).offset(-50);
            
        }];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 40)];
        self.nameLabel.text = _user.login;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.overView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(frame), 40));
            make.centerX.equalTo(self.overView);
            make.top.equalTo(self.avatarButton.mas_bottom);
        }];
        
        
        self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame) - ProfileAvatarHeaderViewSpace)];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImageView.clipsToBounds = YES;
        
        self.bluredCoverImageView = [[UIImageView alloc] initWithFrame:self.coverImageView.bounds];
        self.bluredCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bluredCoverImageView.clipsToBounds = YES;
        
        [self.coverImageView addSubview:self.bluredCoverImageView];
        [self insertSubview:self.coverImageView atIndex:0];
        
        self.gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        self.gaussianBlurFilter.blurRadiusInPixels = 20;
        self.coverImageView.image = self.avatarImage;
        self.bluredCoverImageView.image = [self.gaussianBlurFilter imageByFilteringImage:self.avatarImage];
        
        NSString *(^toString)(NSNumber *) = ^(NSNumber *value) {
            NSString *text = value.stringValue;
            
            if (value.unsignedIntegerValue >= 1000) {
                text = [NSString stringWithFormat:@"%.1fk", value.unsignedIntegerValue / 1000.0];
            }
            return text;
        };
        
        self.followersButton = ({
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) / 3, ProfileAvatarHeaderViewSpace)];
            [btn setFirstLineTitle:toString(@(_user.followers)) secondLineTitle:@"followers"];
            [btn addTarget:self action:@selector(tapFollowerBtn) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self.overView addSubview:self.followersButton];
        [self.followersButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(frame) / 3, ProfileAvatarHeaderViewSpace));
            make.left.equalTo(self.overView.mas_left);
            make.bottom.equalTo(self.overView.mas_bottom);
        }];
        self.repositoriesButton = ({
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) / 3, ProfileAvatarHeaderViewSpace)];
            [btn setFirstLineTitle:toString(@(_user.publicRepoCount)) secondLineTitle:@"repositories"];
            [btn addTarget:self action:@selector(tapRepositoriesBtn) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self.overView addSubview:self.repositoriesButton];
        [self.repositoriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(frame) / 3, ProfileAvatarHeaderViewSpace));
            make.left.equalTo(self.followersButton.mas_right);
            make.bottom.equalTo(self.overView.mas_bottom);
        }];
        self.followingButton = ({
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) / 3, ProfileAvatarHeaderViewSpace)];
            [btn setFirstLineTitle:toString(@(_user.following)) secondLineTitle:@"following"];
            [btn addTarget:self action:@selector(tapFollowingBtn) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
        [self.overView addSubview:self.followingButton];
        [self.followingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(frame) / 3, ProfileAvatarHeaderViewSpace));
            make.right.equalTo(self.overView.mas_right);
            make.bottom.equalTo(self.overView.mas_bottom);
        }];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.overView addBottomBorderWithHeight:kMVC_1PX_WIDTH andColor:[UIColor colorWithHexString:@"0xC8C7CC"]];
}

- (void)setUser:(OCTUser *)user {
    NSString *(^toString)(NSNumber *) = ^(NSNumber *value) {
        NSString *text = value.stringValue;
        if (value.unsignedIntegerValue >= 1000) {
            text = [NSString stringWithFormat:@"%.1fk", value.unsignedIntegerValue / 1000.0];
        }
        return text;
    };
    [self.followersButton setFirstLineTitle:toString(@(user.followers)) secondLineTitle:@"followers"];
    [self.repositoriesButton setFirstLineTitle:toString(@(user.publicRepoCount)) secondLineTitle:@"repositories"];
    [self.followingButton setFirstLineTitle:toString(@(user.following)) secondLineTitle:@"following"];
//    DebugLog(@"set--user=====>%@",user);
    MVCWeakSelf
    [[SDWebImageManager sharedManager] downloadImageWithURL:user.avatarURL
                                                    options:SDWebImageRefreshCached
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (image && finished) {
                                                          __weakSelf.avatarImage = image;
                                                          [__weakSelf.avatarButton setImage:image forState:UIControlStateNormal];
                                                          __weakSelf.coverImageView.image = image;
                                                          __weakSelf.bluredCoverImageView.image = [__weakSelf.gaussianBlurFilter imageByFilteringImage:image];
                                                      }
                                                  }];
    _user = user;
}
#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarButton.imageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarButton.imageView];
    }
    return nil;
}


#pragma mark - Event Response
- (void)clickAvatarBtn {
    MVCSharedAppDelegate.window.backgroundColor = [UIColor blackColor];
    
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:[self.avatarButton imageForState:UIControlStateNormal]];
    viewController.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    viewController.transitioningDelegate = self;
    
    [MVCSharedAppDelegate.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)tapFollowerBtn {
    UserListViewController *userListVC = [[UserListViewController alloc] initWithUserListType:UserListModelTypeFollowers];
    userListVC.user = self.user;
    [self.navgationController pushViewController:userListVC animated:YES];
}

- (void)tapRepositoriesBtn {
    PublicReposViewController *publicReposVC = [[PublicReposViewController alloc] initWithParams:@{ @"user":self.user }];
    [self.navgationController pushViewController:publicReposVC animated:YES];
}

- (void)tapFollowingBtn {
    UserListViewController *userListVC = [[UserListViewController alloc] initWithUserListType:UserListModelTypeFollowing];
    userListVC.user = self.user;
    [self.navgationController pushViewController:userListVC animated:YES];
}

#pragma mark - public methods

- (void)parallaxHeaderInContentOffset:(CGPoint)contentOffset {
    CGFloat correctOffset = contentOffset.y + 64; //偏移量矫正
    if (correctOffset >= 0) {
        return;
    }
    self.coverImageView.frame = CGRectMake(0, 0 + correctOffset, kScreen_Width, CGRectGetHeight(self.frame) + ABS(correctOffset) - ProfileAvatarHeaderViewSpace);
    self.bluredCoverImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.coverImageView.frame), CGRectGetHeight(self.coverImageView.frame));
    
    CGFloat diff = MIN(ABS(correctOffset), ProfileAvatarHeaderViewContentOffsetRadix);
    CGFloat scale = diff / ProfileAvatarHeaderViewContentOffsetRadix;
    
    CGFloat alpha = 1 * (1 - scale);
    
    self.avatarButton.imageView.alpha = alpha;
    self.nameLabel.alpha = alpha;
    self.bluredCoverImageView.alpha = alpha;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
