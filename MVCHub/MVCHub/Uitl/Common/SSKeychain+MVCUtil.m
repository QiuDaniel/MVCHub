//
//  SSKeychain+MVCUtil.m
//  MVCHub
//
//  Created by daniel on 2016/10/15.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "SSKeychain+MVCUtil.h"

@implementation SSKeychain (MVCUtil)

+ (NSString *)rawLogin {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRawLogin];
}

+ (NSString *)password {
    return [self passwordForService:kServiceName account:kPassword];
}

+ (NSString *)accessToken {
    return [self passwordForService:kServiceName account:kAccessToken];
}

+ (BOOL)setRawLogin:(NSString *)rawLogin {
    if (rawLogin == nil) {
        DebugLog(@"+setRawLogin: %@",rawLogin);
    }
    [[NSUserDefaults standardUserDefaults] setObject:rawLogin forKey:kRawLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

+ (BOOL)setPassword:(NSString *)password {
    return [self setPassword:password forService:kServiceName account:kPassword];
}

+ (BOOL)setAccessToken:(NSString *)accessToken {
    return [self setPassword:accessToken forService:kServiceName account:kAccessToken];
}

+ (BOOL)deleteRawLogin {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRawLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

+ (BOOL)deletePassword {
    return [self deletePasswordForService:kServiceName account:kPassword];
}

+ (BOOL)deleteAccessToken {
    return [self deletePasswordForService:kServiceName account:kAccessToken];
}

@end
