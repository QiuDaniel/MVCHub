//
//  Login.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Login.h"

#define kLoginAuthenticatedClient @"authenticated_client"

static OCTUser *curLoginUser;

@implementation Login
- (instancetype)init {
    self = [super init];
    if (self) {
        self.username = @"";
        self.password = @"";
    }
    return self;
}

+ (BOOL)isLogin {
    if ([SSKeychain rawLogin].isExist && [SSKeychain accessToken].isExist) {
        OCTUser *user = [OCTUser mvc_userWithRawLogin:[SSKeychain rawLogin] server:OCTServer.dotComServer];
        OCTClient *authenticatedClient = [OCTClient authenticatedClientWithUser:user token:[SSKeychain accessToken]];
        [MVCHubAPIManager sharedManager].client = authenticatedClient;
        if (user.login == nil) {
            return NO;
        }
        return YES;
        
    } else {
        return NO;
    }

}

+ (void)logIn:(OCTClient *)authenticatedClient {
    if (authenticatedClient) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        curLoginUser = authenticatedClient.user;
        [defaults setObject:curLoginUser.name forKey:@"login"];
        [[MVCMemoryCache sharedInstance] setObject:curLoginUser forKey:@"currentUser"];
        [[MVCMemoryCache sharedInstance] setObject:authenticatedClient forKey:kLoginAuthenticatedClient];
        [authenticatedClient.user mvc_saveOrUpdate];
        [authenticatedClient.user mvc_updateRawLogin]; // The only place to update rawLogin;
        [defaults synchronize];
    } else {
        [Login logOut];
    }
}

+ (void)logOut {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"login"];
    [defaults synchronize];
    [SSKeychain deleteAccessToken];
    [[MVCMemoryCache sharedInstance] removeObjectForKey:@"currentUser"];
}

+ (OCTUser *)curLoginUser {
    if (!curLoginUser) {
        NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
        OCTUser *tempUser = [OCTUser modelWithDictionary:@{
                                                       @"login":login
                                                       } error:nil];
        OCTUser *user = [OCTUser mvc_fetchUser:tempUser];
        curLoginUser = user ?: nil;
    }
    return curLoginUser;
}
@end
