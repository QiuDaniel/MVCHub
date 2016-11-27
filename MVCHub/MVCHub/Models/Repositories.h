//
//  Repositories.h
//  MVCHub
//
//  Created by daniel on 2016/11/8.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ReposViewModelType) {
    ReposViewModelTypeOwned    = 0,
    ReposViewModelTypeStarred  = 1,
    ReposViewModelTypeSearch   = 2,
    ReposViewModelTypePublic   = 3,
    ReposViewModelTypeTrending = 4,
    ReposViewModelTypeShowcase = 5,
    ReposViewModelTypePopular  = 6,
};

typedef NS_OPTIONS(NSUInteger, ReposViewModelOptions) {
    ReposViewModelOptionsObserveStarredReposChange = 1 << 0,
    ReposViewModelOptionsSaveOrUpdateRepos         = 1 << 1,
    ReposViewModelOptionsSaveOrUpdateStarredStatus = 1 << 2,
    ReposViewModelOptionsPagination                = 1 << 3,
    ReposViewModelOptionsSectionIndex              = 1 << 4,
    ReposViewModelOptionsShowOwnerLogin            = 1 << 5,
    ReposViewModelOptionsMarkStarredStatus         = 1 << 6,
};


@interface Repositories : NSObject

@property (nonatomic, strong, readwrite) OCTRepository *repository;

@property (nonatomic, copy, readwrite) NSAttributedString *name, *repoDescription;
@property (nonatomic, copy, readwrite) NSString *updateTime, *language;

@property (nonatomic, assign, readwrite) CGFloat height;
@property (nonatomic, assign, readwrite) ReposViewModelOptions options;

- (instancetype)initWithRepository:(OCTRepository *)repository options:(ReposViewModelOptions) options;
- (instancetype)initWithRepository:(OCTRepository *)repository;

@end
