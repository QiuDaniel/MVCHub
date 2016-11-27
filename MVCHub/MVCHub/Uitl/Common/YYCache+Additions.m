//
//  YYCache+Additions.m
//  MVCHub
//
//  Created by daniel on 2016/11/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "YYCache+Additions.h"

NSString * const ExploreShowcasesCacheKey     = @"ExploreShowcasesCacheKey";
NSString * const ExploreTrendingReposCacheKey = @"ExploreTrendingReposCacheKey";
NSString * const ExplorePopularReposCacheKey  = @"ExplorePopularReposCacheKey";
NSString * const ExplorePopularUsersCacheKey  = @"ExplorePopularUsersCacheKey";

NSString * const TrendingReposLanguageCacheKey = @"TrendingReposLanguageCacheKey";
NSString * const PopularReposLanguageCacheKey  = @"PopularReposLanguageCacheKey";
NSString * const PopularUsersCountryCacheKey   = @"PopularUsersCountryCacheKey";
NSString * const PopularUsersLanguageCacheKey  = @"PopularUsersLanguageCacheKey";

@implementation YYCache (Additions)

+ (instancetype)sharedCache {
    static YYCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *login = [OCTUser mvc_currentUser].login;
        NSParameterAssert(login.length > 0);
        sharedCache = [YYCache cacheWithName:login];
    });
    return sharedCache;
}

+ (NSString *)cacheKeyForReadmeWithRepository:(OCTRepository *)repository reference:(NSString *)reference mediaType:(OCTClientMediaType)mediaType {
    return [NSString stringWithFormat:@"repos/%@/%@/readme?ref=%@&accept=%@",repository.ownerLogin, repository.name, reference, @(mediaType)];
}

@end
