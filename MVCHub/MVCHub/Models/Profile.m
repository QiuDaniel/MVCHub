//
//  Profile.m
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Profile.h"
#import "Login.h"


@implementation Profile

- (instancetype)init {
    self = [super init];
    if (self) {
        id (^map)(NSString *) = ^(NSString *value) {
            return (value.length > 0 && ![value isEqualToString:@"(null)"]) ? value : kEmptyPlaceHolder;
        };
        self.company = map([Login curLoginUser].company);
        self.location = map([Login curLoginUser].location);
        self.email = map([Login curLoginUser].email);
        self.blog = map([Login curLoginUser].blog);
    }
    return self;
}

@end
