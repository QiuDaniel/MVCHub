//
//  YYCache+Additions.h
//  MVCHub
//
//  Created by daniel on 2016/11/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <YYKit/YYKit.h>

extern NSString * const ExploreShowcasesCacheKey;
extern NSString * const ExploreTrendingReposCacheKey;
extern NSString * const ExplorePopularReposCacheKey;
extern NSString * const ExplorePopularUsersCacheKey;

extern NSString * const TrendingReposLanguageCacheKey;
extern NSString * const PopularReposLanguageCacheKey;
extern NSString * const PopularUsersCountryCacheKey;
extern NSString * const PopularUsersLanguageCacheKey;

@interface YYCache (Additions)

+ (instancetype)sharedCache;

+ (NSString *)cacheKeyForReadmeWithRepository:(OCTRepository *)repository reference:(NSString *)reference mediaType:(OCTClientMediaType)mediaType;

@end

