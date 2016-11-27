//
//  OCTRepository+MVCPersistence.m
//  MVCHub
//
//  Created by daniel on 2016/11/1.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OCTRepository+MVCPersistence.h"

#define INSERT_STATEMENT @"INSERT INTO Repository VALUES (:id, :name, :owner_login, :owner_avatar_url, :description, :language, :pushed_at, :created_at, :updated_at, :clone_url, :ssh_url, :git_url, :html_url, :default_branch, :private, :fork, :watchers_count, :forks_count, :stargazers_count, :open_issues_count, :subscribers_count);"
#define UPDATE_STATEMENT @"UPDATE Repository SET name = :name, owner_login = :owner_login, owner_avatar_url = :owner_avatar_url, description = :description, language = :language, pushed_at = :pushed_at, created_at = :created_at, updated_at = :updated_at, clone_url = :clone_url, ssh_url = :ssh_url, git_url = :git_url, html_url = :html_url, default_branch = :default_branch, private = :private, fork = :fork, watchers_count = :watchers_count, forks_count = :forks_count, stargazers_count = :stargazers_count, open_issues_count = :open_issues_count, subscribers_count = :subscribers_count WHERE id = :id;"
#define UPDATE_STATEMENT_LIST @"UPDATE Repository SET name = :name, owner_login = :owner_login, owner_avatar_url = :owner_avatar_url, description = :description, language = :language, pushed_at = :pushed_at, created_at = :created_at, updated_at = :updated_at, clone_url = :clone_url, ssh_url = :ssh_url, git_url = :git_url, html_url = :html_url, default_branch = :default_branch, private = :private, fork = :fork, watchers_count = :watchers_count, forks_count = :forks_count, stargazers_count = :stargazers_count, open_issues_count = :open_issues_count WHERE id = :id;"

@implementation OCTRepository (MVCPersistence)

#pragma mark - Properties

- (OCTRepositoryStarredStatus)starredStatus {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setStarredStatus:(OCTRepositoryStarredStatus)starredStatus {
    objc_setAssociatedObject(self, @selector(starredStatus), @(starredStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - MVCPersistenceProtocol

- (BOOL)mvc_saveOrUpdate {
    __block BOOL result = YES;
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Repository WHERE id = ? LIMIT 1;", self.objectID];
        
        @onExit {
            [rs close];
        };
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        NSString *sql = ![rs next] ? INSERT_STATEMENT : UPDATE_STATEMENT;
        
        BOOL success = [db executeUpdate:sql withParameterDictionary:[self toDBDictionary]];
        if (success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
    }];
    return result;
}

- (BOOL)mvc_delete {
    __block BOOL result = YES;
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"DELETE FROM Repository WHERE id = ?;", self.objectID];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
    }];
    return result;
}

#pragma mark - Save Or Update Repositories
+ (BOOL)mvc_saveOrUpdateRepositories:(NSArray *)repositories {
    if (repositories.count == 0) {
        return YES;
    }
    
    __block BOOL result = YES;
    [[FMDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *oldIDs = nil;
        FMResultSet *rs = [db executeQuery:@"SELECT id FROM Repository;"];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return ;
        }
        
        while ([rs next]) {
            if (oldIDs == nil) {
               oldIDs = [[NSMutableArray alloc] init];
            }
            [oldIDs mvc_addObject:[rs stringForColumnIndex:0]];
        }
        
        for (OCTRepository *repository in repositories) {
            NSString *sql = ![oldIDs containsObject:repository.objectID] ? INSERT_STATEMENT : UPDATE_STATEMENT_LIST;
            BOOL success = [db executeQuery:sql withParameterDictionary:[repository toDBDictionary]];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
    }];
    
    return result;
}

+ (BOOL)mvc_saveOrUpdateStarredStatusWithRepositories:(NSArray *)repositories {
    if (repositories.count == 0) {
        return YES;
    }
    
    __block BOOL result = YES;
    [[FMDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *newIDs = [[repositories.rac_sequence map:^id(OCTUser *user) {
            return user.objectID;
        }].array componentsJoinedByString:@","];
        
        BOOL success = [db executeUpdate:@"DELETE FROM User_Starred_Repository WHERE userId = ? AND repositoryId NOT IN (?);", [OCTUser mvc_currentUserId], newIDs];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return ;
        }
        
        NSMutableArray *oldIDs = nil;
        FMResultSet *rs = [db executeQuery:@"SELECT repositoryId FROM User_Starred_Repository WHERE userId = ?;", [OCTUser mvc_currentUserId]];
        @onExit{
            [rs close];
        };
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        while ([rs next]) {
            if (oldIDs == nil) {
                oldIDs = [[NSMutableArray alloc] init];
            }
            [oldIDs mvc_addObject:[rs stringForColumnIndex:0]];
        }
        
        for (OCTRepository *repository in repositories) {
            if (![oldIDs containsObject:repository.objectID]) {
                success = [db executeUpdate:@"INSERT INTO User_Starred_Repository VALUES (?, ?, ?);",nil, [OCTUser mvc_currentUserId], repository.objectID];
                if (!success) {
                    DebugLogLastError(db);
                    result = NO;
                    return;
                }
            }
        }
    }];
    
    return result;
    
}

#pragma mark - Fetch Repositories

+ (instancetype)mvc_fetchRepository:(OCTRepository *)repository {
    __block OCTRepository *repo = nil;
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Repository WHERE owner_login = ? AND name = ? LIMIT 1;", repository.ownerLogin, repository.name];
        
        @onExit{
            [rs close];
        };
        if (rs == nil) {
            DebugLogLastError(db);
            return ;
        }
        
        if ([rs next]) {
            repo = [OCTRepository fromDBDictionary:rs.resultDictionary];
        }
    }];
    
    return repo;
}

+ (NSArray *)mvc_fetchUserRepositories {
    return [self mvc_fetchUserRepositoriesWithKeyword:nil];
}

+ (NSArray *)mvc_fetchUserRepositoriesWithKeyword:(NSString *)keyword {
    __block NSMutableArray *repos = nil;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *sql = nil;
        
        if (keyword.length == 0) {
            sql = [NSString stringWithFormat:@"SELECT * FROM Repository WHERE owner_login = '%@' ORDER BY LOWER(name);",[OCTUser mvc_currentUser].login];
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM Repository WHERE owner_login = '%@' AND (name LIKE '%%%@%%' OR description LIKE '%%%@%%') ORDER BY LOWER(name);", [OCTUser mvc_currentUser].login, keyword, keyword];
        }
        
        FMResultSet *rs = [db executeQuery:sql];
        
        @onExit{
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            return ;
        }
        
        while ([rs next]) {
            @autoreleasepool {
                if (repos == nil) {
                    repos = [[NSMutableArray alloc] init];
                }
                OCTRepository *repo = [OCTRepository fromDBDictionary:rs.resultDictionary];
                [repos addObject:repo];
            }
        }
    }];
    
    return repos;
}

+ (NSArray *)mvc_fetchUserStarredRepositories {
    return [self mvc_fetchUserStarredRepositoriesWithKeyword:nil];
}

+ (NSArray *)mvc_fetchUserStarredRepositoriesWithKeyword:(NSString *)keyword {
    __block NSMutableArray *repos = nil;
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *sql = nil;
        
        if (keyword.length == 0) {
            sql = [NSString stringWithFormat:@"SELECT * FROM User_Starred_Repository usr, Repository r WHERE usr.userId = '%@' AND usr.repositoryId = r.id ORDER BY LOWER(name);",[OCTUser mvc_currentUserId]];
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM User_Starred_Repository usr, Repository r WHERE usr.userId = '%@' AND usr.repositoryId = r.id AND (r.name LIKE '%%%@%%' OR r.description LIKE '%%%@%%') ORDER BY LOWER(name);", [OCTUser mvc_currentUserId], keyword, keyword];
        }
        
        FMResultSet *rs = [db executeQuery:sql];
        
        @onExit{
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            return ;
        }
        
        while ([rs next]) {
            @autoreleasepool {
                if (repos == nil) repos = [[NSMutableArray alloc] init];
                OCTRepository *repo = [OCTRepository fromDBDictionary:rs.resultDictionary];
                [repos addObject:repo];
            }
        }
    }];
    
    return repos;
}

+ (NSArray *)mvc_fetchUserStarredRepositoriesWithPage:(NSUInteger)page perPage:(NSUInteger)perPage {
    __block NSMutableArray *repos = nil;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = nil;
        
        @onExit {
            [rs close];
        };
        
        NSNumber *limit = @(page * perPage);
        if (![limit isEqualToNumber:@0]) {
            rs = [db executeQuery:@"SELECT * FROM User_Starred_Repository usr, Repository r WHERE usr.userId = ? AND usr.repositoryId = r.id LIMIT = ?;", [OCTUser mvc_currentUserId], limit];
        } else {
            rs = [db executeQuery:@"SELECT * FROM User_Starred_Repository usr, Repository r WHERE usr.userId = ? AND usr.repositoryId = r.id;", [OCTUser mvc_currentUserId]];
        }
        
        if (rs == nil) {
            DebugLogLastError(db);
            return ;
        }
        
        while ([rs next]) {
            @autoreleasepool {
                if (repos == nil) repos = [[NSMutableArray alloc] init];
                OCTRepository *repo = [OCTRepository fromDBDictionary:rs.resultDictionary];
                [repos addObject:repo];
            }
        }
    }];
    return repos;
}

+ (NSArray *)mvc_fetchUserPublicRepositoriesWithPage:(NSUInteger)page perPage:(NSUInteger)perPage {
    __block NSMutableArray *repos = nil;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = nil;
        
        @onExit {
            [rs close];
        };
        
        NSNumber *limit = @(page * perPage);
        if (![limit isEqualToNumber:@0]) {
            rs = [db executeQuery:@"SELECT * FROM Repository WHERE owner_login = ? AND private = 0 ORDER BY LOWER(name) LIMIT ?;", [OCTUser mvc_currentUser].login, limit];
        } else {
            rs = [db executeQuery:@"SELECT * FROM Repository WHERE owner_login = ? AND private = 0 ORDER BY LOWER(name);", [OCTUser mvc_currentUser].login];
        }
        
        if (rs == nil) {
            DebugLogLastError(db);
            return;
        }
        
        while ([rs next]) {
            @autoreleasepool {
                if (repos == nil) repos = [[NSMutableArray alloc] init];
                
                OCTRepository *repo = [OCTRepository fromDBDictionary:rs.resultDictionary];
                [repos addObject:repo];
            }
        }
    }];
    
    return repos;

}

#pragma mark - Star Or Unstar Repository

+ (BOOL)mvc_hasUserStarredRepository:(OCTRepository *)repository {
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM User_Starred_Repository WHERE userId = ? AND repositoryId = ? LIMIT 1;";
        
        FMResultSet *rs = [db executeQuery:sql, [OCTUser mvc_currentUserId], repository.objectID];
        
        @onExit {
            [rs close];
        };
        
        if (!rs) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        result = [rs next];
    }];
    
    return result;
}

+ (BOOL)mvc_starRepository:(OCTRepository *)repository {
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Repository WHERE id = ? LIMIT 1;", repository.objectID];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        if (![rs next]) { // INSERT
            BOOL success = [db executeUpdate:INSERT_STATEMENT withParameterDictionary:[repository toDBDictionary]];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
        
        BOOL success = [db executeUpdate:@"INSERT INTO User_Starred_Repository VALUES (?, ?, ?);", nil, [OCTUser mvc_currentUserId], repository.objectID];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        success = [db executeUpdate:@"UPDATE Repository SET stargazers_count = ? WHERE id = ?;", @(repository.stargazersCount+1), repository.objectID];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        repository.starredStatus = OCTRepositoryStarredStatusYES;
        [repository increaseStargazersCount];
    }];
    
    return result;
}

+ (BOOL)mvc_unstarRepository:(OCTRepository *)repository {
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"DELETE FROM User_Starred_Repository WHERE userId = ? AND repositoryId = ?;", [OCTUser mvc_currentUserId], repository.objectID];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        if (repository.stargazersCount != 0) {
            success = [db executeUpdate:@"UPDATE Repository SET stargazers_count = ? WHERE id = ?;", @(repository.stargazersCount - 1), repository.objectID];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
        
        repository.starredStatus = OCTRepositoryStarredStatusNO;
        [repository decreaseStargazersCount];
    }];
    
    return result;
}

+ (NSArray *)mvc_matchStarredStatusForRepositories:(NSArray *)repositories {
    if (repositories.count == 0) return nil;
    
    NSArray *starredRepos = [self mvc_fetchUserStarredRepositories];
    
    for (OCTRepository *repository in repositories) {
        if (repository.starredStatus != OCTRepositoryStarredStatusUnknown) continue;
        
        repository.starredStatus = OCTRepositoryStarredStatusNO;
        for (OCTRepository *starredRepo in starredRepos) {
            if ([repository.objectID isEqualToString:starredRepo.objectID]) {
                repository.starredStatus = OCTRepositoryStarredStatusYES;
                break;
            }
        }
    }
    
    return repositories;
}

#pragma mark - Private Methods

+ (OCTRepository *)fromDBDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *dic = [dictionary mutableCopy];
    dic[@"owner"] = @{
                      @"login":dictionary[@"owner_login"],
                      @"avatar_url":dictionary[@"owner_avatar_url"]
                      };
    return [MTLJSONAdapter modelOfClass:[OCTRepository class] fromJSONDictionary:dic error:nil];
}

- (NSDictionary *)toDBDictionary {
    NSMutableDictionary *dictionary = [[MTLJSONAdapter JSONDictionaryFromModel:self] mutableCopy];
    dictionary[@"owner_login"] = dictionary[@"owner"][@"login"];
    dictionary[@"owner_avatar_url"] = dictionary[@"owner"][@"avatar_url"];
    
    return dictionary;
}

- (void)increaseStargazersCount {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:self]];
    
    dictionary[@"stargazers_count"] = @([dictionary[@"stargazers_count"] unsignedIntegerValue] + 1);
    OCTRepository *repo = [MTLJSONAdapter modelOfClass:[OCTRepository class] fromJSONDictionary:dictionary error:nil];
    
    [self mergeValueForKey:@"stargazersCount" fromModel:repo];
}

- (void)decreaseStargazersCount {
    if (self.stargazersCount == 0) return;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:self]];
    
    dictionary[@"stargazers_count"] = @([dictionary[@"stargazers_count"] unsignedIntegerValue] - 1);
    OCTRepository *repo = [MTLJSONAdapter modelOfClass:[OCTRepository class] fromJSONDictionary:dictionary error:nil];
    
    [self mergeValueForKey:@"stargazersCount" fromModel:repo];
}

@end
