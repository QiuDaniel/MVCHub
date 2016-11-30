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
        self.company = map([OCTUser mvc_currentUser].company);
        self.location = map([OCTUser mvc_currentUser].location);
        self.email = map([OCTUser mvc_currentUser].email);
        self.blog = map([OCTUser mvc_currentUser].blog);
    }
    return self;
}

@end
