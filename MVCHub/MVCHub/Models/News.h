//
//  News.h
//  MVCHub
//
//  Created by daniel on 2016/10/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NewsViewType) {
    NewsViewTypeNews,
    NewsViewTypePublicActivity
};

extern NSInteger const NewsPerPage;

@interface News : NSObject

@property (nonatomic, assign) NewsViewType type;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger page;

- (instancetype)initWithType:(NewsViewType) type;

@end
