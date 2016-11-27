//
//  NSURL+MVCLinkType.m
//  MVCHub
//
//  Created by daniel on 2016/10/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "NSURL+MVCLinkType.h"

static NSString *const MVCLinkUserScheme = @"user";
static NSString *const MVCLinkRepositoryScheme = @"repository";

@implementation NSURL (MVCLinkType)

- (MVCLinkType)type {
    if ([self.scheme isEqualToString:MVCLinkUserScheme]) {
        return MVCLinkTypeUser;
    } else if ([self.scheme isEqualToString:MVCLinkRepositoryScheme]) {
        return MVCLinkTypeRepository;
    }
    return MVCLinkTypeUnknown;
}

+ (instancetype)mvc_userLinkWithLogin:(NSString *)login {
    NSParameterAssert(login.length > 0);
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", MVCLinkUserScheme, login]];
}

+ (instancetype)mvc_repositoryLinkWithName:(NSString *)name referenceName:(NSString *)referenceName {
    NSParameterAssert(name.length > 0);
    referenceName = referenceName ?: DefaultReferenceName();
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@?referenceName=%@",MVCLinkRepositoryScheme, name, referenceName]];
}

- (NSDictionary *)mvc_dictionary {
    if (self.type == MVCLinkTypeUser) {
        return @{
                 @"user": @{
                         @"login": self.host ?: @""
                         }
                 };
    } else if (self.type == MVCLinkTypeRepository) {
        return @{
                 @"repository": @{
                         @"ownerLogin":self.host ?: @"",
                         @"name":[self.path substringFromIndex:1] ?: @"",
                         },
                 @"referenceName":[self.query componentsSeparatedByString:@"="].lastObject ?: @""
                 };
    }
    return nil;
}

@end

@implementation OCTEvent (MVCLinkType)

- (NSURL *)mvc_Link {
    NSMutableAttributedString *attributedString = nil;
    
    if ([self isMemberOfClass:[OCTCommitCommentEvent class]]) {
        attributedString = self.mvc_commentedCommitAttributedString;
    } else if ([self isMemberOfClass:[OCTForkEvent class]]) {
        attributedString = self.mvc_forkedRepositoryNameAttributedString;
    } else if ([self isMemberOfClass:[OCTIssueCommentEvent class]]) {
        attributedString = self.mvc_issueAttributedString;
    } else if ([self isMemberOfClass:[OCTIssueEvent class]]) {
        attributedString = self.mvc_issueAttributedString;
    } else if ([self isMemberOfClass:[OCTMemberEvent class]]) {
        attributedString = self.mvc_memberLoginAttributedString;
    } else if ([self isMemberOfClass:[OCTPublicEvent class]]) {
        attributedString = self.mvc_repositoryNameAttributedString;
    } else if ([self isMemberOfClass:[OCTPullRequestCommentEvent class]]) {
        attributedString = self.mvc_pullRequestAttributedString;
    } else if ([self isMemberOfClass:[OCTPullRequestEvent class]]) {
        attributedString = self.mvc_pullRequestAttributedString;
    } else if ([self isMemberOfClass:[OCTPushEvent class]]) {
        attributedString = self.mvc_branchNameAttributedString;
    } else if ([self isMemberOfClass:[OCTRefEvent class]]) {
        if ([self.mvc_refNameAttributedString attribute:LinkAttributeName atIndex:0 effectiveRange:NULL]) {
            attributedString = self.mvc_refNameAttributedString;
        } else {
            attributedString = self.mvc_repositoryNameAttributedString;
        }
    } else if ([self isMemberOfClass:[OCTWatchEvent class]]) {
        attributedString = self.mvc_repositoryNameAttributedString;
    }
    
    return [attributedString attribute:LinkAttributeName atIndex:0 effectiveRange:NULL];
}

@end

