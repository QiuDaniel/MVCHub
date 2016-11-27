//
//  ProfileAvatarHeaderView.h
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileAvatarHeaderView : UIView

@property (nonatomic, strong) OCTUser *user;
@property (nonatomic, strong) UINavigationController *navgationController;

- (instancetype)initWithFrame:(CGRect)frame user:(OCTUser *)user;
- (void)parallaxHeaderInContentOffset:(CGPoint)contentOffset;

@end
