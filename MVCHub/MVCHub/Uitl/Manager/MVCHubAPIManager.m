//
//  MVCHubAPIManager.m
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "MVCHubAPIManager.h"
#import "MKNetworkKit.h"

@interface MVCHubAPIManager ()


@end

@implementation MVCHubAPIManager

+ (instancetype)sharedManager {
    static MVCHubAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Login
- (void)requestLoginWithUsername:(NSString *)username password:(NSString *)password oneTimePassword:(NSString *)oneTimePassword scopes:(OCTClientAuthorizationScopes)scopes andBlock:(void (^)(OCTClient *authenticatedClient, NSError *error))block {
    [OCTClient setClientID:kGitHub_CLIENT_ID clientSecret:kGitHub_CLIENT_SECRET];
    OCTUser *user = [OCTUser userWithRawLogin:username server:OCTServer.dotComServer];
    [[OCTClient signInAsUser:user password:password oneTimePassword:oneTimePassword scopes:scopes note:nil noteURL:nil fingerprint:nil] subscribeNext:^(OCTClient *authenticatedClient) {
        self.client = authenticatedClient;
        block(authenticatedClient, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - OAuthLogin
- (void)requestLoginWithCode:(NSString *)code andBlock:(void (^)(OCTClient *authenticatedClient, NSError *error))block {
    OCTClient *client = [[OCTClient alloc] initWithServer:[OCTServer dotComServer]];
    [OCTClient setClientID:kGitHub_CLIENT_ID clientSecret:kGitHub_CLIENT_SECRET];
    [[[[[client exchangeAccessTokenWithCode:code] doNext:^(OCTAccessToken *accessToken) {
        [client setValue:accessToken.token forKey:@"token"];
    }] flattenMap:^(id value) {
        return [[client fetchUserInfo] doNext:^(OCTUser *user) {
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
            [mutableDic addEntriesFromDictionary:user.dictionaryValue];
            
            if (user.rawLogin.length == 0) {
                mutableDic[@keypath(user.rawLogin)] = user.login;
            }
            
            user = [OCTUser modelWithDictionary:mutableDic error:nil];
            [client setValue:user forKey:@"user"];
        }];
    }] mapReplace:client] subscribeNext:^(OCTClient *client) {
        self.client = client;
        block(client, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Follower & Following
- (void)requestUserListWithUser:(OCTUser *)user userListType:(UserListModelType)type location:(NSString *)location language:(NSString *)language page:(NSUInteger)page perPage:(NSUInteger)perPage andBlock:(void (^)(NSArray *data, NSError *error))block {
    
    NSArray *preUsers = type == UserListModelTypeFollowing ? [OCTUser mvc_fetchFollowingWithPage:1 perPage:perPage] : [OCTUser mvc_fetchFollowersWithPage:1 perPage:perPage];
    NSUInteger (^offsetForPage)(NSUInteger) = ^(NSUInteger page) {
        return (page - 1) * perPage;
    };
    NSArray *(^mapFollowingStatus)(NSArray *) = ^(NSArray *users) {
        if (page == 1) {
            for (OCTUser *user in users) {
                if (user.followerStatus == OCTUserFollowingStatusYES) continue;
                
                for (OCTUser *preUser in preUsers) {
                    if ([user.objectID isEqualToString:preUser.objectID]) {
                        user.followingStatus = preUser.followingStatus;
                        break;
                    }
                }
            }
        } else {
            if ([user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
                users = @[(preUsers ?: @[]).rac_sequence, users.rac_sequence].
                rac_sequence.flatten.array;
            }
        }
        return users;
    };
    
    if (type == UserListModelTypeFollowers) {
        [[[[[[[self.client fetchFollowersForUser:user offset:offsetForPage(page) perPage:perPage]
          take:perPage ]
          collect]
         map:^(NSArray *users) {
            for (OCTUser *user in users) {
                if ([user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) user.followerStatus = OCTUserFollowerStatusYES;
            }
            return users;
        }]
    map:mapFollowingStatus]
    doNext:^(NSArray *users) {
        if ([user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [OCTUser mvc_saveOrUpdateUsers:users];
                [OCTUser mvc_saveOrUpdateFollowerStatusWithUsers:users];
            });
        }
        
    }] subscribeNext:^(NSArray *users) {
        block(users, nil);

    } error:^(NSError *error) {
        block(nil, error);

    }];
    } else if (type == UserListModelTypeFollowing) {
        [[[[[[[self.client fetchFollowingForUser:user offset:offsetForPage(page) perPage:perPage]
         take:perPage]
         collect]
        map:^(NSArray *users) {
            for (OCTUser *user in users) {
                if ([user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
                    user.followingStatus = OCTUserFollowingStatusYES;
                }
            }
            return users;
        }]
         map:mapFollowingStatus]
        doNext:^(NSArray *users) {
            if ([user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [OCTUser mvc_saveOrUpdateUsers:users];
                    [OCTUser mvc_saveOrUpdateFollowingStatusWithUsers:users];
                });
            }
        }] subscribeNext:^(NSArray *users) {
            block(users, nil);
        } error:^(NSError *error) {
            block(nil, error);
            
        }];
    } else if (type == UserListModelTypePopularUsers) {
        [[[self.client fetchPopularUsersWithLocation:location language:language] map:mapFollowingStatus] subscribeNext:^(NSArray *users) {
            block(users, nil);
        } error:^(NSError *error) {
            block(nil, error);
        }];
    }
    
}

#pragma mark - UserInfo
- (void)requestUserInfoForUser:(OCTUser *)user andBlock:(void(^)(OCTUser *user, NSError *error))block{
    [[[[[self.client fetchUserInfoForUser:user] retry:3] doNext:^(OCTUser *user) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [user mvc_saveOrUpdate];
        });
    }] deliverOnMainThread] subscribeNext:^(OCTUser *user) {
        block(user, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - News (Received Events & Performed Events)
- (void)requestNewsForUser:(OCTUser *)user newsType:(NewsViewType)type page:(NSUInteger)page perPage:(NSUInteger)perPage andBlock:(void (^)(NSArray *data, NSError *error))block {
    NSUInteger (^offsetForPage)(NSUInteger) = ^(NSUInteger page) {
        return (page - 1) * perPage;
    };

    RACSignal *requestSignal = [RACSignal empty];
    if (type == NewsViewTypeNews) {
        requestSignal = [self.client fetchUserReceivedEventsWithOffset:offsetForPage(page) perPage:perPage];
    } else if (type == NewsViewTypePublicActivity) {
        requestSignal = [self.client fetchPerformedEventsForUser:user offset:offsetForPage(page) perPage:perPage];
    }
    
    [[[[requestSignal take:perPage] collect] doNext:^(NSArray *events) {
        if ([user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
            if (type == NewsViewTypeNews) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [OCTEvent mvc_saveUserReceivedEvents:events];
                });
            } else if (type == NewsViewTypePublicActivity) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [OCTEvent mvc_saveUserPerformedEvents:events];
                });
            }
        }
    }] subscribeNext:^(NSArray *events) {
        block(events, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
    
}

#pragma mark - Repository
- (void)requestRepositoryWithName:(NSString *)name owner:(NSString *)owner andBlock:(void (^)(id data, NSError *error))block {
    [[[[[self.client fetchRepositoryWithName:name owner:owner] retry:3] doNext:^(OCTRepository *repo) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [repo mvc_saveOrUpdate];
        });
    }] deliverOnMainThread] subscribeNext:^(OCTRepository *repo) {
        block(repo, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Readme
- (void)requestRepositoryReadmeWithRepository:(OCTRepository *)repo reference:(NSString *)reference andBlock:(void (^)(id data, NSError *error))block{
    [[[[self.client fetchRepositoryReadme:repo reference:reference mediaType:OCTClientMediaTypeHTML] doNext:^(RACTuple *tuple) {
        [[YYCache sharedCache] setObject:tuple forKey:[YYCache cacheKeyForReadmeWithRepository:repo reference:reference mediaType:OCTClientMediaTypeHTML] withBlock:nil];
    }] deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
        NSString *summaryHTML = [NSString summaryReadmeHTMLFromReadmeHTML:(NSString *)tuple];
        block(summaryHTML, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - GitTree
- (void)requestGitTreeForReference:(NSString *)reference inRepository:(OCTRepository *)repository andBlock:(void (^)(id data, NSError *error))block {
    [[[self.client fetchTreeForReference:reference inRepository:repository recursive:YES] deliverOnMainThread] subscribeNext:^(OCTTree *tree) {
        block(tree, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - GitTree(Cache)
- (void)requestGitTreeCacheForReference:(NSString *)reference inRepository:(OCTRepository *)repository andBlock:(void(^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/git/trees/%@",repository.ownerLogin, repository.name, [reference componentsSeparatedByString:@"/"].lastObject];
    NSMutableURLRequest *request = [self.client requestWithMethod:@"GET" path:path parameters:@{ @"recursive": @1}];
    NSCachedURLResponse *URLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (URLResponse.data) {
        block(URLResponse.data, nil);
    } else {
        block(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil]);
    }
}

#pragma mark - Branch or Tag
- (void)requestAllReferencesInRepository:(OCTRepository *)repository andBlcok:(void(^)(id data, NSError *error))block {
    [[[self.client fetchAllReferencesInRepository:repository] collect] subscribeNext:^(NSArray *references) {
        block(references, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Star Repository
- (void)requestToStarRepository:(OCTRepository *)repository andBlock:(void (^)(id data, NSError *error))block{
    if (repository.starredStatus == OCTRepositoryStarredStatusYES) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([OCTRepository mvc_starRepository:repository]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MVCStarredReposDidChangeNotification object:nil];
        }
    });
    [[[self.client starRepository:repository] deliverOnMainThread] subscribeError:^(NSError *error) {
        block(nil, error);
    } completed:^{
        block(@(OCTRepositoryStarredStatusYES), nil);
    }];
}

#pragma mark - Unsatr Repository
- (void)requestToUnstarRepository:(OCTRepository *)repository andBlock:(void(^)(id data, NSError *error))block {
    if (repository.starredStatus == OCTRepositoryStarredStatusNO) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([OCTRepository mvc_unstarRepository:repository]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MVCStarredReposDidChangeNotification object:nil];
        }
    });
    [[[self.client unstarRepository:repository] deliverOnMainThread] subscribeError:^(NSError *error) {
        block(nil, error);
    } completed:^{
        block(@(OCTRepositoryStarredStatusNO), nil);
    }];

}

#pragma mark - Current User's Repositories
- (void)requestForUserRepositoriesAndBlock:(void(^)(id data, NSError *error))block {
    [[[[self.client fetchUserRepositories] collect] doNext:^(NSArray *repositories) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [OCTRepository mvc_saveOrUpdateRepositories:repositories];
        });
    }] subscribeNext:^(NSArray *repositories) {
        block(repositories, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Current User's StarredRepositories
- (void)requestUserStarredRepositoriesAndBlock:(void(^)(id data, NSError *error))block {
    [[[[[self.client fetchUserStarredRepositories] collect] map:^(NSArray *repositories) {
        for (OCTRepository *repository in repositories) {
            repository.starredStatus = OCTRepositoryStarredStatusYES;
        }
        return repositories;
    }] doNext:^(NSArray *repositories) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [OCTRepository mvc_saveOrUpdateStarredStatusWithRepositories:repositories];
            [OCTRepository mvc_saveOrUpdateRepositories:repositories];
        });
    } ] subscribeNext:^(NSArray *repositories) {
        block(repositories, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Specified User's StarredRepositores
- (void)requestStarredRepositoriesForUser:(OCTUser *)user page:(NSInteger)page perPage:(NSInteger)perPage andBlock:(void(^)(NSArray *data, NSError *error))block {
    NSInteger (^offsetForPage)(NSInteger) = ^(NSInteger page) {
        return (page - 1) * perPage;
    };
    
    [[[[[self.client fetchStarredRepositoriesForUser:user offset:offsetForPage(page) perPage:perPage] take:perPage] collect] doNext:^(NSArray *repositories) {
        if ([user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
            for (OCTRepository *repo in repositories) {
                repo.starredStatus = OCTRepositoryStarredStatusYES;
            }
        }
    }] subscribeNext:^(NSArray *repositories) {
        block(repositories, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - TrendingRepositories
- (void)requestTrendingRepositoriesSince:(NSString *)since language:(NSString *)language andBlock:(void(^)(id data, NSError *error))block {
    since = since ?:@"";
    language = language ?: @"";
    NSString *URLString = [NSString stringWithFormat:@"http://trending.codehub-app.com/v2/trending?since=%@&language=%@", since, language];
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MKNetworkEngine *networkEngine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *operation = [networkEngine operationWithURLString:URLString];
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *jsonArray = completedOperation.responseJSON;
            if (jsonArray.count > 0) {
                NSError *error = nil;
                NSArray *repositories = [MTLJSONAdapter modelsOfClass:[OCTRepository class] fromJSONArray:jsonArray error:&error];
                if (error) {
                    DebugLogError(error);
                    block(nil, error);
                } else {
                    block(repositories, nil);
                }
            }
        });
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(nil, error);
        });
    }];
    
    [networkEngine enqueueOperation:operation];
    if (operation.isFinished) {
        [operation cancel];
    }
    
}

#pragma mark - PopularRepositories
- (void)requestPopularRepositoriesWithLanguage:(NSString *)language andBlock:(void(^)(id data, NSError *error))block {
    [[[[self.client fetchPopularRepositoriesWithLanguage:language] retry:3] doNext:^(NSArray *popularRepos) {
        
    }] subscribeNext:^(NSArray *popularRepos) {
        block(popularRepos, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - PopularUsers
- (void)requestPopularUsersWithLocation:(NSString *)location language:(NSString *)language andBlock:(void(^)(id data, NSError *error))block {
    [[[[self.client fetchPopularUsersWithLocation:location language:language] retry:3] doNext:^(NSArray *popularUsers) {

    }] subscribeNext:^(NSArray *popularUsers) {
        block(popularUsers, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Showcases
- (void)requestShowcasesAndBlock:(void(^)(id data, NSError *error))block {
    NSString *URLString = @"http://trending.codehub-app.com/v2/showcases";
    MKNetworkEngine *networkEngine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *operation = [networkEngine operationWithURLString:URLString];
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *jsonArray = completedOperation.responseJSON;
            if (jsonArray.count > 0) {
                NSArray *showcases = [NSObject arrayFromJSON:jsonArray ofObjects:@"Showcase"];
                [[YYCache sharedCache] setObject:showcases forKey:ExploreTrendingReposCacheKey withBlock:nil];
                block(showcases, nil);
                
            }
        });

    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(nil, error);
        });
    }];
    
    [networkEngine enqueueOperation:operation];
    if (operation.isFinished) {
        [operation cancel];
    }
}

#pragma mark - ShowcaseRepositories
- (void)requestShowcaseRepositoriesWithSlug:(NSString *)slug andBlock:(void(^)(id data, NSError *error))block {
    NSParameterAssert(slug.length > 0);
    NSString *URLString = [NSString stringWithFormat:@"http://trending.codehub-app.com/v2/showcases/%@", slug];
    MKNetworkEngine *networkEngine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *operation = [networkEngine operationWithURLString:URLString];
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *jsonArray = completedOperation.responseJSON[@"repositories"];
            NSError *error = nil;
            NSArray *repositories = [MTLJSONAdapter modelsOfClass:[OCTRepository class] fromJSONArray:jsonArray error:&error];
            if (error) {
                DebugLogError(error);
                block(nil, error);
            } else {
                block(repositories, nil);
            }
        });
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(nil, error);
        });
    }];
    
    [networkEngine enqueueOperation:operation];
    if (operation.isFinished) {
        [operation cancel];
    }
}

#pragma mark - Public Repositories For User
- (void)requestPublicRepositoriesForUser:(OCTUser *)user page:(NSUInteger)page perPage:(NSUInteger)perPage andBlock:(void(^)(NSArray *data, NSError *error))block {
    NSUInteger (^offsetForPage)(NSUInteger) = ^(NSUInteger page) {
        return (page - 1) * perPage;
    };
    
    [[[[self.client fetchPublicRepositoriesForUser:user offset:offsetForPage(page) perPage:perPage] take:perPage] collect] subscribeNext:^(NSArray *repositories) {
        block(repositories, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Create Issue
- (void)createIssueWithTitle:(NSString *)title content:(NSString *)content inRepository:(OCTRepository *)repository andBlock:(void(^)(NSNumber *state, NSError *error))block {
    [[[self.client createIssueWithTitle:title body:content assignee:nil milestone:0 labels:nil inRepository:repository] deliverOnMainThread] subscribeNext:^(NSNumber *state) {
        block(state, nil);
    } error:^(NSError *error) {
        block(nil, error);
    }];
}
@end
