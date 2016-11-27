//
//  RepoDetail.m
//  MVCHub
//
//  Created by daniel on 2016/11/3.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RepoDetail.h"
#import "TTTTimeIntervalFormatter.h"

@implementation RepoDetail

- (instancetype)initWithRepository:(OCTRepository *)repository {
    self = [super init];
    if (self) {
        self.title = [repository.name copy];
        self.subTitle = [repository.ownerLogin copy];
        self.repoDescription = [repository.repoDescription copy];
        
//        NSError *error = nil;
//        self.reference = [[OCTRef alloc] initWithDictionary:@{@"name": referenceName} error:&error];
//        if (error) DebugLogError(error);
        
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        timeIntervalFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        RAC(self, dateUpdated) = [[RACObserve(repository, dateUpdated) ignore:nil] map:^id(NSDate *dateUpdated) {
            return [NSString stringWithFormat:@"Updated %@", [timeIntervalFormatter stringForTimeIntervalFromDate:NSDate.date toDate:dateUpdated]];
        }];
        
        self.forksCount = [NSNumber numberWithUnsignedInteger:repository.forksCount];
        self.subscribersCount = [NSNumber numberWithUnsignedInteger:repository.subscribersCount];
        RAC(self, stargazersCount) = [[RACObserve(repository, stargazersCount)
                                       ignore:nil]
                                      map:^id(NSNumber *stargazersCount) {
                                          return stargazersCount;
                                      }];

        //self.stargazersCount = [NSNumber numberWithUnsignedInteger:repository.stargazersCount];
    
//        NSString *HTMLString = (NSString *)[[YYCache sharedCache] objectForKey:[YYCache cacheKeyForReadmeWithRepository:repository reference:self.reference.name mediaType:OCTClientMediaTypeHTML]];
//        self.summaryReadmeHTML = [NSString summaryReadmeHTMLFromReadmeHTML:HTMLString];
    }
    return self;
}

@end
