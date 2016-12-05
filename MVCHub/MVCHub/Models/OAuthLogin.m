//
//  OAuthLogin.m
//  MVCHub
//
//  Created by daniel on 2016/12/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OAuthLogin.h"

@implementation OAuthLogin

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"OAuth2 Authorization Login";
        CFUUIDRef UUID = CFUUIDCreate(NULL);
        self.UUIDString = CFBridgingRelease(CFUUIDCreateString(NULL, UUID));
        CFRelease(UUID);
        DebugLog(@"UUID========>%@",self.UUIDString);
        NSString *URLString = [NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&scope=%@&state=%@", kGitHub_CLIENT_ID,@"user,repo",self.UUIDString];
        NSURL *URL = [NSURL URLWithString:URLString];
        self.request = [NSURLRequest requestWithURL:URL];
    }
    return self;
}

@end
