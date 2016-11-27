//
//  UserDetail.m
//  MVCHub
//
//  Created by daniel on 2016/10/19.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "UserDetail.h"

@implementation UserDetail

- (instancetype)initWithUser:(OCTUser *)user {
    self = [super init];
    if (self) {
        self.user = user;
    }
    return self;
}

- (void)setUser:(OCTUser *)user {
    id (^map)(NSString *) = ^(NSString *value) {
        return (value.length > 0 && ![value isEqualToString:@"(null)"]) ? value : kEmptyPlaceHolder;
    };
    _name = [user.name copy];
    _company = [map(user.company) copy];
    _location = [map(user.location) copy];
    _email = [map(user.email) copy];
    _blog = [map(user.blog) copy];
    _user = user;
}
@end
