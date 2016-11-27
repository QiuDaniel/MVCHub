//
//  UserListViewController.h
//  MVCHub
//
//  Created by daniel on 2016/10/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

@class UserList;

@interface UserListViewController : BaseViewController

@property (nonatomic, strong) OCTUser *user;

- (instancetype)initWithUserListType:(UserListModelType)userListType;

@end
