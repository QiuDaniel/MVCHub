//
//  UserListTableViewCell.h
//  MVCHub
//
//  Created by daniel on 2016/10/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define UserListTableViewCellLeftImageViewWidth 55
extern NSInteger const UserListTableViewCellLeftImageViewWidth;

@interface UserListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *loginLabel, *htmlLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;

@end
