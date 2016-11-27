//
//  UserDetailViewController.h
//  MVCHub
//
//  Created by daniel on 2016/10/19.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

@interface UserDetailViewController : BaseViewController


- (instancetype)initWithUser:(OCTUser *)user;
- (instancetype)initWithParams:(NSDictionary *)params;

@end
