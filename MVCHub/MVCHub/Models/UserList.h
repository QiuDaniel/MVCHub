//
//  UserList.h
//  MVCHub
//
//  Created by daniel on 2016/10/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserListModelType) {
    UserListModelTypeFollowers,
    UserListModelTypeFollowing,
    UserListModelTypePopularUsers,
};

extern NSInteger const UserListPerPage;

@interface UserList : NSObject

@property (nonatomic, assign) NSInteger page;

- (NSUInteger)offsetForPage:(NSUInteger)page;

@end
