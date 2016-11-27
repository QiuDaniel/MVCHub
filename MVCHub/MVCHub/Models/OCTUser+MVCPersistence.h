//
//  OCTUser+MVCPersistence.h
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <OctoKit/OctoKit.h>
#import "MVCPersistenceProtocol.h"

typedef NS_ENUM(NSUInteger, OCTUserFollowerStatus) {
    OCTUserFollowerStatusUnkown,
    OCTUserFollowerStatusYES,
    OCTUserFollowerStatusNO
};

typedef NS_ENUM(NSUInteger, OCTUserFollowingStatus) {
    OCTUserFollowingStatusUnkown,
    OCTUserFollowingStatusYES,
    OCTUserFollowingStatusNO
};

@interface OCTUser (MVCPersistence) <MVCPersistenceProtocol>

@property (nonatomic, assign) OCTUserFollowerStatus followerStatus;
@property (nonatomic, assign) OCTUserFollowingStatus followingStatus;

- (BOOL)mvc_updateRawLogin;

+ (BOOL)mvc_saveOrUpdateUsers:(NSArray *)users;
+ (BOOL)mvc_saveOrUpdateFollowerStatusWithUsers:(NSArray *)users;
+ (BOOL)mvc_saveOrUpdateFollowingStatusWithUsers:(NSArray *)users;

+ (NSString *)mvc_currentUserId;

+ (instancetype)mvc_userWithRawLogin:(NSString *)rawLogin server:(OCTServer *)server;
+ (instancetype)mvc_currentUser;
+ (instancetype)mvc_fetchUserWithRawLogin:(NSString *)rawLogin;
+ (instancetype)mvc_fetchUser:(OCTUser *)user;

+ (BOOL)mvc_followUser:(OCTUser *)user;
+ (BOOL)mvc_unFollowUser:(OCTUser *)user;

+ (NSArray *)mvc_fetchFollowersWithPage:(NSUInteger)page perPage:(NSUInteger)perPage;
+ (NSArray *)mvc_fetchFollowingWithPage:(NSUInteger)page perPage:(NSUInteger)perPage;

@end
