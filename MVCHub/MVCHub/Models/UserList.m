//
//  UserList.m
//  MVCHub
//
//  Created by daniel on 2016/10/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

//#define UserListPerPage 10;

#import "UserList.h"

NSInteger const UserListPerPage = 10;


@implementation UserList

- (instancetype)init {
    self = [super init];
    if (self) {
        self.page = 1;
    }
    return self;
}

- (NSUInteger)offsetForPage:(NSUInteger)page {
    return (page - 1) * UserListPerPage;
}

@end
