//
//  MVCHubAPIManager.h
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserList.h"
#import "News.h"

@interface MVCHubAPIManager : NSObject


+ (instancetype)sharedManager;

#pragma mark - Login

- (void)requestLoginWithUsername:(NSString *)username password:(NSString *)password oneTimePassword:(NSString *)oneTimePassword scopes:(OCTClientAuthorizationScopes)scopes andBlock:(void (^)(OCTClient *authenticatedClient, NSError *error))block;

#pragma mark - Follower & Following
/**
 Request to fetches the followers or following for the specified 'user'

 @param user    The specified user. This must not be nil.
 @param type    Via the type to return followers or following.
 @param location country
 @param language program language
 @param page    The page parameter.
 @param perPage The perPage parameter. You can set a custom page size up to 100 and the    
                default value 30 will be used if you pass 0 or greater than 100.
 @param block   Return a data which sends error or more OCTUser objects.
 */
- (void)requestUserListWithUser:(OCTUser *)user userListType:(UserListModelType)type location:(NSString *)location language:(NSString *)language page:(NSUInteger)page perPage:(NSUInteger)perPage andBlock:(void (^)(NSArray *data, NSError *error))block;

#pragma mark - UserInfo

/**
 Request to fetches user infomation for the specified 'user'

 @param user The specified user. This must not be nil.
 */
- (void)requestUserInfoForUser:(OCTUser *)user andBlock:(void(^)(OCTUser *user, NSError *error))block;

#pragma mark - News (Received Events & Performed Events)

- (void)requestNewsForUser:(OCTUser *)user newsType:(NewsViewType)type page:(NSUInteger)page perPage:(NSUInteger)perPage andBlock:(void(^)(NSArray *data, NSError *error))block;

#pragma mark - Repository
- (void)requestRepositoryWithName:(NSString *)name owner:(NSString *)owner andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - Readme
- (void)requestRepositoryReadmeWithRepository:(OCTRepository *)repo reference:(NSString *)reference andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - GitTree
- (void)requestGitTreeForReference:(NSString *)reference inRepository:(OCTRepository *)repository andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - GitTree(Cache)
- (void)requestGitTreeCacheForReference:(NSString *)reference inRepository:(OCTRepository *)repository andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - Branch or Tag
- (void)requestAllReferencesInRepository:(OCTRepository *)repository andBlcok:(void(^)(id data, NSError *error))block;

#pragma mark - Star Repository
- (void)requestToStarRepository:(OCTRepository *)repository andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - Unsatr Repository
- (void)requestToUnstarRepository:(OCTRepository *)repository andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - Current User's Repositories
- (void)requestForUserRepositoriesAndBlock:(void(^)(id data, NSError *error))block;

#pragma mark - Current User's StarredRepositories
- (void)requestUserStarredRepositoriesAndBlock:(void(^)(id data, NSError *error))block;

#pragma mark - TrendingRepositories
- (void)requestTrendingRepositoriesSince:(NSString *)since language:(NSString *)language andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - PopularRepositories
- (void)requestPopularRepositoriesWithLanguage:(NSString *)language andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - PopularUsers
- (void)requestPopularUsersWithLocation:(NSString *)location language:(NSString *)language andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - Showcases;
- (void)requestShowcasesAndBlock:(void(^)(id data, NSError *error))block;

#pragma mark - ShowcaseRepositories
- (void)requestShowcaseRepositoriesWithSlug:(NSString *)slug andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - Public Repositories For User
- (void)requestPublicRepositoriesForUser:(OCTUser *)user page:(NSUInteger)page perPage:(NSUInteger)perPage andBlock:(void(^)(NSArray *data, NSError *error))block;

#pragma mark - Create Issue
- (void)createIssueWithTitle:(NSString *)title content:(NSString *)content inRepository:(OCTRepository *)repository andBlock:(void(^)(NSNumber *state, NSError *error))block;
@end
