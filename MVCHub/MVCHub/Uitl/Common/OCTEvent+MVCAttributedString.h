//
//  OCTEvent+MVCAttributedString.h
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <OctoKit/OctoKit.h>

typedef NS_OPTIONS(NSUInteger, EventOptions) {
    EventOptionsBoldTitle = 1 << 0
};

@interface OCTEvent (MVCAttributedString)

@property (nonatomic, assign, readonly) EventOptions options;

- (NSMutableAttributedString *)mvc_attributedString;

- (NSMutableAttributedString *)mvc_commitCommentEventAttributedString;
- (NSMutableAttributedString *)mvc_forkEventAttributedString;
- (NSMutableAttributedString *)mvc_issueCommentEventAttributedString;
- (NSMutableAttributedString *)mvc_issueEventAttributedString;
- (NSMutableAttributedString *)mvc_memberEventAttributedString;
- (NSMutableAttributedString *)mvc_publicEventAttributedString;
- (NSMutableAttributedString *)mvc_pullRequestCommentEventAttributedString;
- (NSMutableAttributedString *)mvc_pullRequestEventAttributedString;
- (NSMutableAttributedString *)mvc_pushEventAttributedString;
- (NSMutableAttributedString *)mvc_refEventAttributedString;
- (NSMutableAttributedString *)mvc_watchEventAttributedString;

- (NSMutableAttributedString *)mvc_octiconAttributedString;
- (NSMutableAttributedString *)mvc_actorLoginAttributedString;
- (NSMutableAttributedString *)mvc_commentedCommitAttributedString;
- (NSMutableAttributedString *)mvc_forkedRepositoryNameAttributedString;
- (NSMutableAttributedString *)mvc_repositoryNameAttributedString;
- (NSMutableAttributedString *)mvc_issueAttributedString;
- (NSMutableAttributedString *)mvc_memberLoginAttributedString;
- (NSMutableAttributedString *)mvc_pullRequestAttributedString;
- (NSMutableAttributedString *)mvc_branchNameAttributedString;
- (NSMutableAttributedString *)mvc_pushedCommitAttributedStringWithSHA:(NSString *)SHA;
- (NSMutableAttributedString *)mvc_pushedCommitsAttributedString;
- (NSMutableAttributedString *)mvc_refNameAttributedString;
- (NSMutableAttributedString *)mvc_dateAttributedString;
- (NSMutableAttributedString *)mvc_pullInfoAttributedString;

@end
