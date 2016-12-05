//
//  OAuthLogin.h
//  MVCHub
//
//  Created by daniel on 2016/12/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthLogin : NSObject

@property (nonatomic, copy) NSString *UUIDString, *title;
@property (nonatomic, copy) NSURLRequest *request;

@end
