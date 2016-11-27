//
//  UserDetail.h
//  MVCHub
//
//  Created by daniel on 2016/10/19.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDetail : NSObject

@property (nonatomic, strong) OCTUser *user;
@property (nonatomic, copy) NSString *name, *company, *location, *email, *blog;

- (instancetype)initWithUser:(OCTUser *)user;

@end
