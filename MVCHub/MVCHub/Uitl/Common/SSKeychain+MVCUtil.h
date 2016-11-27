//
//  SSKeychain+MVCUtil.h
//  MVCHub
//
//  Created by daniel on 2016/10/15.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>

@interface SSKeychain (MVCUtil)

+ (NSString *)rawLogin;
+ (NSString *)password;
+ (NSString *)accessToken;

+ (BOOL)setRawLogin:(NSString *)rawLogin;
+ (BOOL)setPassword:(NSString *)password;
+ (BOOL)setAccessToken:(NSString *)accessToken;

+ (BOOL)deleteRawLogin;
+ (BOOL)deletePassword;
+ (BOOL)deleteAccessToken;

@end
