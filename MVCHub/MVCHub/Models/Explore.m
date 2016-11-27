//
//  Explore.m
//  MVCHub
//
//  Created by daniel on 2016/11/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Explore.h"

@implementation Explore

- (instancetype)initWithObject:(id)object {
    self = [super init];
    if (self) {
        self.object = object;
        if ([object isKindOfClass:[OCTRepository class]]) {
            self.name = ((OCTRepository *)object).name;
            self.ownerAvatarURL = ((OCTRepository *)object).ownerAvatarURL;
        } else if ([object isKindOfClass:[OCTUser class]]) {
            self.name = ((OCTUser *)object).name;
            self.ownerAvatarURL = ((OCTUser *)object).avatarURL;
        }
    }
    return self;
}
@end
