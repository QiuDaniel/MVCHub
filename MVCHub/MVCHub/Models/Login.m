//
//  Login.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Login.h"

#define kLoginStatus @"login_status"
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
    NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    if (loginStatus.boolValue && [Login curLoginUser]) {
        OCTUser *user = [Login curLoginUser];
        if (user.rawLogin == nil) {
            return NO;
        }
        return YES;
    }else {
        return NO;
    }
}

+ (void)logIn:(OCTClient *)authenticatedClient {
    if (authenticatedClient) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kLoginStatus];
//        [defaults setObject:authenticatedClient forKey:kLoginAuthenticatedClient];
        [[MVCMemoryCache sharedInstance] setObject:authenticatedClient.user forKey:@"currentUser"];
        [[MVCMemoryCache sharedInstance] setObject:authenticatedClient forKey:kLoginAuthenticatedClient];
        [authenticatedClient.user mvc_saveOrUpdate];
        [authenticatedClient.user mvc_updateRawLogin]; // The only place to update rawLogin;
        curLoginUser = authenticatedClient.user;
        [defaults synchronize];
    } else {
        [Login logOut];
    }
}

+ (void)logOut {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:kLoginStatus];
    [defaults synchronize];
    [SSKeychain deleteAccessToken];
    [[MVCMemoryCache sharedInstance] removeObjectForKey:@"currentUser"];
}

+ (OCTUser *)curLoginUser {
    if (!curLoginUser) {
        OCTClient *client = [[MVCMemoryCache sharedInstance] objectForKey:kLoginAuthenticatedClient];
        curLoginUser = client? client.user: nil;
    }
    return curLoginUser;
}
@end
