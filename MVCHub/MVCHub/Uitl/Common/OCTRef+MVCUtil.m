//
//  OCTRef+MVCUtil.m
//  MVCHub
//
//  Created by daniel on 2016/11/5.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OCTRef+MVCUtil.h"

@implementation OCTRef (MVCUtil)

- (NSString *)octiconIdentifier {
    NSArray *components = [self.name componentsSeparatedByString:@"/"];
    if (components.count == 3) {
        if ([components[1] isEqualToString:@"heads"]) { // refs/heads/master
            return @"GitBranch";
        } else if ([components[1] isEqualToString:@"tags"]) { // refs/tags/v0.0.1
            return @"Tag";
        }
    }
    return @"GitBranch";
}

@end
