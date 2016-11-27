//
//  OCTUser+MVCPersistence.m
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OCTUser+MVCPersistence.h"

#define INSERT_STATEMENT @"INSERT INTO User (id, login, name, bio, email, avatar_url, html_url, blog, company, location, collaborators, public_repos, owned_private_repos, public_gists, private_gists, followers, following, disk_usage) VALUES (:id, :login, :name, :bio, :email, :avatar_url, :html_url, :blog, :company, :location, :collaborators, :public_repos, :owned_private_repos, :public_gists, :private_gists, :followers, :following, :disk_usage);"
#define UPDATE_STATEMENT @"UPDATE User SET login = :login, name = :name, bio = :bio, email = :email, avatar_url = :avatar_url, html_url = :html_url, blog = :blog, company = :company, location = :location, collaborators = :collaborators, public_repos = :public_repos, owned_private_repos = :owned_private_repos, public_gists = :public_gists, private_gists = :private_gists, followers = :followers, following = :following, disk_usage = :disk_usage WHERE id = :id;"
#define UPDATE_STATEMENT_LIST @"UPDATE User SET login = :login, bio = :bio, avatar_url = :avatar_url, html_url = :html_url, collaborators = :collaborators, owned_private_repos = :owned_private_repos, public_gists = :public_gists, private_gists = :private_gists, disk_usage = :disk_usage WHERE id = :id;"

@implementation OCTUser (MVCPersistence)

#pragma mark - Properties

- (OCTUserFollowerStatus)followerStatus {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setFollowerStatus:(OCTUserFollowerStatus)followerStatus {
    objc_setAssociatedObject(self, @selector(followerStatus), @(followerStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (OCTUserFollowingStatus)followingStatus {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setFollowingStatus:(OCTUserFollowingStatus)followingStatus {
    objc_setAssociatedObject(self, @selector(followingStatus), @(followingStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - MVCPersistanceProtocol

- (BOOL)mvc_saveOrUpdate {
    __block BOOL result = YES;
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM User WHERE id = ? LIMIT 1;", self.objectID];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        NSString *sql = ![rs next] ? INSERT_STATEMENT : UPDATE_STATEMENT;
        
        BOOL success = [db executeUpdate:sql withParameterDictionary:[MTLJSONAdapter JSONDictionaryFromModel:self]];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
    }];
    return result;
}

- (BOOL)mvc_delete {
    return YES;
}

#pragma mark - Save Or Update Users

- (BOOL)mvc_updateRawLogin {
    __block BOOL result = YES;
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM User WHERE id = ? LIMIT 1;", self.objectID];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        if([rs next]) {
            BOOL success = [db executeUpdate:@"UPDATE User SET rawLogin = ? WHERE id = ?;", self.rawLogin, self.objectID];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
    }];
    
    return result;
}

+ (BOOL)mvc_saveOrUpdateUsers:(NSArray *)users {
    if (users.count == 0) {
        return YES;
    }
    
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *oldIDs = nil;
        
        FMResultSet *rs = [db executeQuery:@"SELECT id FROM User;"];
        
        @onExit {
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
        for (OCTUser *user in users) {
            NSString *sql = ![oldIDs containsObject:user.objectID] ? INSERT_STATEMENT : UPDATE_STATEMENT_LIST;
            
            BOOL success = [db executeUpdate:sql withParameterDictionary:[MTLJSONAdapter JSONDictionaryFromModel:user]];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
        
    }];
    
    return result;
}

+ (BOOL)mvc_saveOrUpdateFollowerStatusWithUsers:(NSArray *)users {
    if (users.count == 0) {
        return YES;
    }
    
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *newIDs = [[users.rac_sequence map:^(OCTUser *user) {
            return user.objectID;
        }].array componentsJoinedByString:@","];
        /*****这段代码是为了比较RAC写法和普通写法*************
        NSMutableArray *idArr = [[NSMutableArray alloc] init];
        for (OCTUser *user in users) {
            [idArr addObject:user.objectID];
        }
        NSString *sameIDs = [idArr componentsJoinedByString:@","];
        DebugLog(@"newIDs======>%@", newIDs);
        DebugLog(@"sameIds======>%@",sameIDs);
        ******************/
        
        BOOL success = [db executeUpdate:@"DELETE FROM User_Following_User WHERE userId NOT IN (?) AND targetUserId = ?;", newIDs, [OCTUser mvc_currentUserId]];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        FMResultSet *rs = [db executeQuery:@"SELECT userId FROM User_Following_User WHERE targetUserId = ?;", [OCTUser mvc_currentUserId]];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        NSMutableArray *oldIDs = nil;
        while ([rs next]) {
            if (oldIDs == nil) {
                oldIDs = [[NSMutableArray alloc] init];
            }
            [oldIDs mvc_addObject:[rs stringForColumnIndex:0]];
        }
        
        for (OCTUser *user in users) {
            if (![oldIDs containsObject:user.objectID]) { // INSERT
                success = [db executeUpdate:@"INSERT INTO User_Following_User VALUES (?, ?, ?);", nil, user.objectID, [OCTUser mvc_currentUserId]];
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

+ (BOOL)mvc_saveOrUpdateFollowingStatusWithUsers:(NSArray *)users {
    if (users.count == 0) return YES;
    
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *newIDs = [[users.rac_sequence map:^id(OCTUser *user) {
            return user.objectID;
        }].array componentsJoinedByString:@","];
        
        BOOL success = [db executeUpdate:@"DELETE FROM User_Following_User WHERE targetUserId NOT IN (?) AND userId = ?;", newIDs, [OCTUser mvc_currentUserId]];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        FMResultSet *rs = [db executeQuery:@"SELECT targetUserId FROM User_Following_User WHERE userId = ?;", [OCTUser mvc_currentUserId]];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        NSMutableArray *oldIDs = nil;
        while ([rs next]) {
            if (oldIDs == nil) oldIDs = [[NSMutableArray alloc] init];
            [oldIDs mvc_addObject:[rs stringForColumnIndex:0]];
        }
        
        for (OCTUser *user in users) {
            if (![oldIDs containsObject:user.objectID]) { // INSERT
                success = [db executeUpdate:@"INSERT INTO User_Following_User VALUES (?, ?, ?);", nil, [OCTUser mvc_currentUserId], user.objectID];
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

#pragma mark - Fetch UserId 

+ (NSString *)mvc_currentUserId {
    return ((OCTUser *)[self mvc_currentUser ]).objectID;
}

#pragma mark - Fetch User

+ (instancetype)mvc_userWithRawLogin:(NSString *)rawLogin server:(OCTServer *)server {
    NSParameterAssert(rawLogin.length > 0);
    NSParameterAssert(server);
    
    OCTUser *user = [self mvc_fetchUserWithRawLogin:rawLogin];
    NSParameterAssert(user && user.login.length > 0);
    
    NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
    if (rawLogin.length > 0) userDict[@"rawLogin"] = rawLogin;
    if (user.login.length > 0) userDict[@"login"] = user.login;
    if (server.baseURL) userDict[@"baseURL"] = server.baseURL;
    
    return [self modelWithDictionary:userDict error:nil];
}

+ (instancetype)mvc_currentUser {
    OCTUser *currentUser = [[MVCMemoryCache sharedInstance] objectForKey:@"currentUser"];
    if (!currentUser) {
        currentUser = [self mvc_fetchUserWithRawLogin:[SSKeychain rawLogin]];
        
        NSAssert(currentUser != nil, @"The retrieved currentUser must not be nil.");
        [[MVCMemoryCache sharedInstance] setObject:currentUser forKey:@"currentUser"];
    }
    
    return currentUser;
}

+ (instancetype)mvc_fetchUserWithRawLogin:(NSString *)rawLogin {
    if (rawLogin.length == 0) return nil;
    
    __block OCTUser *user = nil;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM User WHERE rawLogin = ? OR login = ? OR email = ? LIMIT 1;", rawLogin, rawLogin, rawLogin];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            return;
        }
        
        if ([rs next]) {
            user = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:rs.resultDictionary error:nil];
        }
    }];
    
    return user;
}

+ (instancetype)mvc_fetchUser:(OCTUser *)user {
    __block OCTUser *result = nil;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM User WHERE login = ? LIMIT 1;", user.login];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            return;
        }
        
        if ([rs next]) {
            result = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:rs.resultDictionary error:nil];
        }
    }];
    
    return result;
}

+ (BOOL)mvc_followUser:(OCTUser *)user {
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM User WHERE id = ? LIMIT 1;", user.objectID];
        
        @onExit {
            [rs close];
        };
        
        if (rs == nil) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        if (![rs next]) { // INSERT
            BOOL success = [db executeUpdate:INSERT_STATEMENT withParameterDictionary:[MTLJSONAdapter JSONDictionaryFromModel:user]];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
        
        BOOL success = [db executeUpdate:@"INSERT INTO User_Following_User VALUES (?, ?, ?);", nil, [OCTUser mvc_currentUserId], user.objectID];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        success = [db executeUpdate:@"UPDATE User SET followers = ? WHERE id = ?;", @(user.followers+1), user.objectID];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        success = [db executeUpdate:@"UPDATE User SET following = ? WHERE id = ?;", @([OCTUser mvc_currentUser].following+1), [OCTUser mvc_currentUserId]];
        if (!success) {
            DebugLogLastError(db);
            result = NO;
            return;
        }
        
        user.followingStatus = OCTUserFollowingStatusYES;
        [user increaseFollowers];
        [[OCTUser mvc_currentUser] increaseFollowing];
    }];
    
    return result;
}

+ (BOOL)mvc_unFollowUser:(OCTUser *)user {
    __block BOOL result = YES;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"DELETE FROM User_Following_User WHERE userId = ? AND targetUserId = ?;", [OCTUser mvc_currentUserId], user.objectID];
        
        if (user.followers != 0) {
            success = [db executeUpdate:@"UPDATE User SET followers = ? WHERE id = ?;", @(user.followers-1), user.objectID];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
        
        if ([OCTUser mvc_currentUser].following != 0) {
            success = [db executeUpdate:@"UPDATE User SET following = ? WHERE id = ?;", @([OCTUser mvc_currentUser].following-1), [OCTUser mvc_currentUserId]];
            if (!success) {
                DebugLogLastError(db);
                result = NO;
                return;
            }
        }
        
        user.followingStatus = OCTUserFollowingStatusNO;
        [user decreaseFollowers];
        [[OCTUser mvc_currentUser] decreaseFollowing];
    }];
    
    return result;
}

#pragma mark - Fetch Users

+ (NSArray *)mvc_fetchFollowersWithPage:(NSUInteger)page perPage:(NSUInteger)perPage {
    __block NSMutableArray *followers = nil;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = nil;
        
        @onExit {
            [rs close];
        };
        
        NSNumber *limit = @(page * perPage);
        if (![limit isEqualToNumber:@0]) {
            rs = [db executeQuery:@"SELECT * FROM User_Following_User ufu, User u WHERE ufu.targetUserId = ? AND ufu.userId = u.id LIMIT ?;", [OCTUser mvc_currentUserId], limit];
        } else {
            rs = [db executeQuery:@"SELECT * FROM User_Following_User ufu, User u WHERE ufu.targetUserId = ? AND ufu.userId = u.id;", [OCTUser mvc_currentUserId]];
        }
        
        if (rs == nil) {
            DebugLogLastError(db);
            return;
        }
        
        while ([rs next]) {
            @autoreleasepool {
                if (followers == nil) followers = [[NSMutableArray alloc] init];
                OCTUser *user = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:rs.resultDictionary error:nil];
                user.followerStatus = OCTUserFollowerStatusYES;
                [followers addObject:user];
            }
        }
    }];
    
    return followers;
}

+ (NSArray *)mvc_fetchFollowingWithPage:(NSUInteger)page perPage:(NSUInteger)perPage {
    __block NSMutableArray *followings = nil;
    
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = nil;
        
        @onExit {
            [rs close];
        };
        
        NSNumber *limit = @(page * perPage);
        if (![limit isEqualToNumber:@0]) {
            rs = [db executeQuery:@"SELECT * FROM User_Following_User ufu, User u WHERE ufu.userId = ? AND ufu.targetUserId = u.id ORDER BY u.id LIMIT ?;", [OCTUser mvc_currentUserId], limit];
        } else {
            rs = [db executeQuery:@"SELECT * FROM User_Following_User ufu, User u WHERE ufu.userId = ? AND ufu.targetUserId = u.id ORDER BY u.id;", [OCTUser mvc_currentUserId]];
        }
        
        if (rs == nil) {
            DebugLogLastError(db);
            return;
        }
        
        while ([rs next]) {
            @autoreleasepool {
                if (followings == nil) followings = [[NSMutableArray alloc] init];
                OCTUser *user = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:rs.resultDictionary error:nil];
                user.followingStatus = OCTUserFollowingStatusYES;
                [followings addObject:user];
            }
        }
    }];
    
    return followings;
}

- (void)increaseFollowers {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:self]];
    
    dictionary[@"followers"] = @([dictionary[@"followers"] unsignedIntegerValue] + 1);
    OCTUser *user = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:dictionary error:nil];
    
    [self mergeValueForKey:@"followers" fromModel:user];
}

- (void)decreaseFollowers {
    if (self.followers == 0) return;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:self]];
    
    dictionary[@"followers"] = @([dictionary[@"followers"] unsignedIntegerValue] - 1);
    OCTUser *user = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:dictionary error:nil];
    
    [self mergeValueForKey:@"followers" fromModel:user];
}

- (void)increaseFollowing {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:self]];
    
    dictionary[@"following"] = @([dictionary[@"following"] unsignedIntegerValue] + 1);
    OCTUser *user = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:dictionary error:nil];
    
    [self mergeValueForKey:@"following" fromModel:user];
}

- (void)decreaseFollowing {
    if (self.following == 0) return;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:self]];
    
    dictionary[@"following"] = @([dictionary[@"following"] unsignedIntegerValue] - 1);
    OCTUser *user = [MTLJSONAdapter modelOfClass:[OCTUser class] fromJSONDictionary:dictionary error:nil];
    
    [self mergeValueForKey:@"following" fromModel:user];
}

@end
