//
//  News.m
//  MVCHub
//
//  Created by daniel on 2016/10/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "News.h"

NSInteger const NewsPerPage = 20;

@implementation News

- (instancetype)initWithType:(NewsViewType)type{
    self = [super init];
    if (self) {
        self.page = 1;
        self.type = type;
        if (self.type == NewsViewTypeNews) {
            self.title = @"News";
        } else if (self.type == NewsViewTypePublicActivity) {
            self.title = @"Public Activity";
        }
    }
    
    return self;
}
@end
