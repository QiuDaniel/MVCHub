//
//  Login.h
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Login : NSObject

@property (nonatomic, copy, readonly) NSURL *avatarURL;
@property (nonatomic, copy, readwrite) NSString *username, *password;

+ (BOOL)isLogin;
+ (void)logIn:(OCTClient *)authenticatedClient;
+ (void)logOut;
+ (OCTUser *)curLoginUser;
@end
