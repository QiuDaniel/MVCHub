//
//  RepoDetail.h
//  MVCHub
//
//  Created by daniel on 2016/11/3.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RepoDetail : NSObject

@property (nonatomic, copy, readwrite) NSArray *references;
@property (nonatomic, strong) OCTRef *reference;

@property (nonatomic, copy, readwrite) NSString *title, *subTitle, *dateUpdated, *repoDescription;
@property (nonatomic, strong, readwrite) NSNumber *forksCount, *subscribersCount, *stargazersCount;

- (instancetype)initWithRepository:(OCTRepository *)repository;

@end
