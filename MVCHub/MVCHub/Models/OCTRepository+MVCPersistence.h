//
//  OCTRepository+MVCPersistence.h
//  MVCHub
//
//  Created by daniel on 2016/11/1.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <OctoKit/OctoKit.h>
#import "MVCPersistenceProtocol.h"

typedef NS_ENUM(NSInteger, OCTRepositoryStarredStatus) {
    OCTRepositoryStarredStatusUnknown,
    OCTRepositoryStarredStatusYES,
    OCTRepositoryStarredStatusNO
};

@interface OCTRepository (MVCPersistence) <MVCPersistenceProtocol>

@property (nonatomic, assign) OCTRepositoryStarredStatus starredStatus;

+ (BOOL)mvc_saveOrUpdateRepositories:(NSArray *)repositories;
+ (BOOL)mvc_saveOrUpdateStarredStatusWithRepositories:(NSArray *)repositories;

+ (instancetype)mvc_fetchRepository:(OCTRepository *)repository;
+ (NSArray *)mvc_fetchUserRepositories;
+ (NSArray *)mvc_fetchUserRepositoriesWithKeyword:(NSString *)keyword;
+ (NSArray *)mvc_fetchUserStarredRepositories;
+ (NSArray *)mvc_fetchUserStarredRepositoriesWithKeyword:(NSString *)keyword;
+ (NSArray *)mvc_fetchUserStarredRepositoriesWithPage:(NSUInteger)page perPage:(NSUInteger)perPage;
+ (NSArray *)mvc_fetchUserPublicRepositoriesWithPage:(NSUInteger)page perPage:(NSUInteger)perPage;

+ (BOOL)mvc_hasUserStarredRepository:(OCTRepository *)repository;
+ (BOOL)mvc_starRepository:(OCTRepository *)repository;
+ (BOOL)mvc_unstarRepository:(OCTRepository *)repository;

+ (NSArray *)mvc_matchStarredStatusForRepositories:(NSArray *)repositories;

@end
