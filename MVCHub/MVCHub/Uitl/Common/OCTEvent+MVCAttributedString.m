//
//  OCTEvent+MVCAttributedString.m
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OCTEvent+MVCAttributedString.h"
#import "TTTTimeIntervalFormatter.h"

@implementation OCTEvent (MVCAttributedString)

- (EventOptions)options {
    EventOptions options = 0;
    
    if ([self isMemberOfClass:[OCTCommitCommentEvent class]] ||
        [self isMemberOfClass:[OCTIssueCommentEvent class]] ||
        [self isMemberOfClass:[OCTIssueEvent class]] ||
        [self isMemberOfClass:[OCTPullRequestCommentEvent class]] ||
        [self isMemberOfClass:[OCTPullRequestEvent class]] ||
        [self isMemberOfClass:[OCTPushEvent class]]) {
        options |= EventOptionsBoldTitle;
    }
    
    return options;
}

- (NSMutableAttributedString *)mvc_attributedString {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:self.mvc_octiconAttributedString];
    [attributedString appendAttributedString:self.mvc_actorLoginAttributedString];
    
    if ([self isMemberOfClass:[OCTCommitCommentEvent class]] ||
        [self isMemberOfClass:[OCTIssueCommentEvent class]] ||
        [self isMemberOfClass:[OCTPullRequestCommentEvent class]]) {
        if ([self isMemberOfClass:[OCTCommitCommentEvent class]]) {
            [attributedString appendAttributedString:[self mvc_commitCommentEventAttributedString]];
        } else if ([self isMemberOfClass:[OCTIssueCommentEvent class]]) {
            [attributedString appendAttributedString:[self mvc_issueCommentEventAttributedString]];
        } else if ([self isMemberOfClass:[OCTPullRequestCommentEvent class]]) {
            [attributedString appendAttributedString:[self mvc_pullRequestCommentEventAttributedString]];
        }
        
        [attributedString appendAttributedString:[@"\n" stringByAppendingString:[self valueForKeyPath:@"comment.body"]].mvc_attributedString.mvc_addNormalTitleAttributes.mvc_addParagraphStyleAttribute];
    } else if ([self isMemberOfClass:[OCTForkEvent class]]) {
        [attributedString appendAttributedString:[self mvc_forkEventAttributedString]];
    } else if ([self isMemberOfClass:[OCTIssueEvent class]]) {
        [attributedString appendAttributedString:[self mvc_issueEventAttributedString]];
    } else if ([self isMemberOfClass:[OCTMemberEvent class]]) {
        [attributedString appendAttributedString:[self mvc_memberEventAttributedString]];
    } else if ([self isMemberOfClass:[OCTPublicEvent class]]) {
        [attributedString appendAttributedString:[self mvc_publicEventAttributedString]];
    } else if ([self isMemberOfClass:[OCTPullRequestEvent class]]) {
        [attributedString appendAttributedString:[self mvc_pullRequestEventAttributedString]];
    } else if ([self isMemberOfClass:[OCTPushEvent class]]) {
        [attributedString appendAttributedString:[self mvc_pushEventAttributedString]];
    } else if ([self isMemberOfClass:[OCTRefEvent class]]) {
        [attributedString appendAttributedString:[self mvc_refEventAttributedString]];
    } else if ([self isMemberOfClass:[OCTWatchEvent class]]) {
        [attributedString appendAttributedString:[self mvc_watchEventAttributedString]];
    }
    
    [attributedString appendAttributedString:self.mvc_dateAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_octiconAttributedString {
    OCTIcon icon = 0;
    if ([self isMemberOfClass:[OCTCommitCommentEvent class]] ||
        [self isMemberOfClass:[OCTIssueCommentEvent class]] ||
        [self isMemberOfClass:[OCTPullRequestCommentEvent class]]) {
        icon = OCTIconCommentDiscussion;
    } else if ([self isMemberOfClass:[OCTForkEvent class]]) {
        icon = OCTIconGitBranch;
    } else if ([self isMemberOfClass:[OCTIssueEvent class]]) {
        OCTIssueEvent *concreteEvent = (OCTIssueEvent *)self;
        
        if (concreteEvent.action == OCTIssueActionOpened) {
            icon = OCTIconIssueOpened;
        } else if (concreteEvent.action == OCTIssueActionClosed) {
            icon = OCTIconIssueClosed;
        } else if (concreteEvent.action == OCTIssueActionReopened) {
            icon = OCTIconIssueReopened;
        }
    } else if ([self isMemberOfClass:[OCTMemberEvent class]]) {
        icon = OCTIconOrganization;
    } else if ([self isMemberOfClass:[OCTPublicEvent class]]) {
        icon = OCTIconRepo;
    } else if ([self isMemberOfClass:[OCTPullRequestEvent class]]) {
        icon = OCTIconGitPullRequest;
    } else if ([self isMemberOfClass:[OCTPushEvent class]]) {
        icon = OCTIconGitCommit;
    } else if ([self isMemberOfClass:[OCTRefEvent class]]) {
        OCTRefEvent *concreteEvent = (OCTRefEvent *)self;
        
        if (concreteEvent.refType == OCTRefTypeBranch) {
            icon = OCTIconGitBranch;
        } else if (concreteEvent.refType == OCTRefTypeTag) {
            icon = OCTIconTag;
        } else if (concreteEvent.refType == OCTRefTypeRepository) {
            icon = OCTIconRepo;
        }
    } else if ([self isMemberOfClass:[OCTWatchEvent class]]) {
        icon = OCTIconStar;
    }
    
    return [[NSString octicon_iconStringForEnum:icon] stringByAppendingString:@"  "].mvc_attributedString.mvc_addOcticonAttributes;
}

- (NSMutableAttributedString *)mvc_actorLoginAttributedString {
    return [self mvc_loginAttributedStringWithString:self.actorLogin];
}

- (NSMutableAttributedString *)mvc_loginAttributedStringWithString:(NSString *)string {
    NSMutableAttributedString *attributedString = string.mvc_attributedString;
    
    if (self.options & EventOptionsBoldTitle) {
        [attributedString mvc_addBoldTitleFontAttribute];
    } else {
        [attributedString mvc_addNormalTitleFontAttribute];
    }
    
    [attributedString mvc_addTintedForegroundColorAttribute];
    [attributedString mvc_addUserLinkAttribute];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_commentedCommitAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTCommitCommentEvent class]]);
    
    OCTCommitCommentEvent *concreteEvent = (OCTCommitCommentEvent *)self;
    
    NSString *target = [NSString stringWithFormat:@"%@@%@", concreteEvent.repositoryName, ShortSHA(concreteEvent.comment.commitSHA)];
    NSMutableAttributedString *attributedString = target.mvc_attributedString;
    
    NSURL *HTMLURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?title=Commit", concreteEvent.comment.HTMLURL.absoluteString]];
    
    [attributedString mvc_addBoldTitleFontAttribute];
    [attributedString mvc_addTintedForegroundColorAttribute];
    [attributedString mvc_addHTMLURLAttribute:HTMLURL];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_forkedRepositoryNameAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTForkEvent class]]);
    
    OCTForkEvent *concreteEvent = (OCTForkEvent *)self;
    
    return [self mvc_repositoryNameAttributedStringWithString:concreteEvent.forkedRepositoryName];
}

- (NSMutableAttributedString *)mvc_repositoryNameAttributedString {
    return [self mvc_repositoryNameAttributedStringWithString:self.repositoryName];
}

- (NSMutableAttributedString *)mvc_repositoryNameAttributedStringWithString:(NSString *)string {
    NSMutableAttributedString *attributedString = string.mvc_attributedString;
    
    if (self.options & EventOptionsBoldTitle) {
        attributedString = attributedString.mvc_addBoldTitleFontAttribute;
    } else {
        attributedString = attributedString.mvc_addNormalTitleAttributes;
    }
    
    return [attributedString.mvc_addTintedForegroundColorAttribute mvc_addRepositoryLinkAttributeWithName:attributedString.string referenceName:nil];
}

- (NSMutableAttributedString *)mvc_issueAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTIssueCommentEvent class]] || [self isMemberOfClass:[OCTIssueEvent class]]);
    
    OCTIssue *issue = [self valueForKey:@"issue"];
    
    NSString *issueID = [issue.URL.absoluteString componentsSeparatedByString:@"/"].lastObject;
    NSURL *HTMLURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?title=Issue-@%@", issue.HTMLURL.absoluteString, issueID]];
    
    NSMutableAttributedString *attributedString = [NSString stringWithFormat:@"%@#%@", self.repositoryName, issueID].mvc_attributedString;
    
    [attributedString mvc_addBoldTitleFontAttribute];
    [attributedString mvc_addTintedForegroundColorAttribute];
    [attributedString mvc_addHTMLURLAttribute:HTMLURL];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_memberLoginAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTMemberEvent class]]);
    
    return [self mvc_loginAttributedStringWithString:[self valueForKey:@"memberLogin"]];
}

- (NSMutableAttributedString *)mvc_pullRequestAttributedString {
    NSParameterAssert([self isKindOfClass:[OCTPullRequestCommentEvent class]] || [self isMemberOfClass:[OCTPullRequestEvent class]]);
    
    NSString *pullRequestID = nil;
    NSURL *HTMLURL = nil;
    if ([self isKindOfClass:[OCTPullRequestCommentEvent class]]) {
        OCTPullRequestCommentEvent *concreteEvent = (OCTPullRequestCommentEvent *)self;
        
        pullRequestID = [concreteEvent.comment.pullRequestAPIURL.absoluteString componentsSeparatedByString:@"/"].lastObject;
        
        HTMLURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?title=Pull-Request-@%@", concreteEvent.comment.HTMLURL.absoluteString, pullRequestID]];
    } else if ([self isMemberOfClass:[OCTPullRequestEvent class]]) {
        OCTPullRequestEvent *concreteEvent = (OCTPullRequestEvent *)self;
        
        pullRequestID = [concreteEvent.pullRequest.URL.absoluteString componentsSeparatedByString:@"/"].lastObject;
        
        HTMLURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?title=Pull-Request-@%@", concreteEvent.pullRequest.HTMLURL.absoluteString, pullRequestID]];
    }
    
    NSParameterAssert(pullRequestID.length > 0);
    NSParameterAssert(HTMLURL);
    
    NSMutableAttributedString *attributedString = [NSString stringWithFormat:@"%@#%@", self.repositoryName, pullRequestID].mvc_attributedString;
    
    [attributedString mvc_addBoldTitleFontAttribute];
    [attributedString mvc_addTintedForegroundColorAttribute];
    [attributedString mvc_addHTMLURLAttribute:HTMLURL];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_branchNameAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTPushEvent class]]);
    
    NSString *branchName = [self valueForKey:@"branchName"];
    
    NSMutableAttributedString *attributedString = branchName.mvc_attributedString;
    
    [attributedString mvc_addBoldTitleFontAttribute];
    [attributedString mvc_addTintedForegroundColorAttribute];
    [attributedString mvc_addRepositoryLinkAttributeWithName:self.repositoryName referenceName:ReferenceNameWithBranchName(branchName)];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_pushedCommitAttributedStringWithSHA:(NSString *)SHA {
    NSParameterAssert([self isMemberOfClass:[OCTPushEvent class]]);
    
    NSMutableAttributedString *attributedString = ShortSHA(SHA).mvc_attributedString;
    
    NSURL *HTMLURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@/commit/%@?title=Commit", self.repositoryName, SHA]];
    
    [attributedString mvc_addNormalTitleFontAttribute];
    [attributedString mvc_addTintedForegroundColorAttribute];
    [attributedString mvc_addHTMLURLAttribute:HTMLURL];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_pushedCommitsAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTPushEvent class]]);
    
    OCTPushEvent *concreteEvent = (OCTPushEvent *)self;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    for (NSDictionary *dictionary in concreteEvent.commits) {
        /* {
         "sha": "6e4dc62cffe9f2d1b1484819936ee264dde36592",
         "author": {
         "email": "coderyi@foxmail.com",
         "name": "coderyi"
         },
         "message": "增加iOS开发者coderyi的博客\n\n增加iOS开发者coderyi的博客",
         "distinct": true,
         "url": "https://api.github.com/repos/tangqiaoboy/iOSBlogCN/commits/6e4dc62cffe9f2d1b1484819936ee264dde36592"
         } */
        NSMutableAttributedString *commit = [[NSMutableAttributedString alloc] init];
        
        [commit appendAttributedString:@"\n".mvc_attributedString];
        [commit appendAttributedString:[self mvc_pushedCommitAttributedStringWithSHA:dictionary[@"sha"]]];
        [commit appendAttributedString:[@" - " stringByAppendingString:dictionary[@"message"]].mvc_attributedString.mvc_addNormalTitleAttributes];
        
        [attributedString appendAttributedString:commit];
    }
    
    return attributedString.mvc_addParagraphStyleAttribute;
}

- (NSMutableAttributedString *)mvc_refNameAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTRefEvent class]]);
    
    OCTRefEvent *concreteEvent = (OCTRefEvent *)self;
    
    if (!concreteEvent.refName) return @" ".mvc_attributedString;
    
    NSMutableAttributedString *attributedString = concreteEvent.refName.mvc_attributedString;
    
    [attributedString mvc_addNormalTitleFontAttribute];
    
    if (concreteEvent.eventType == OCTRefEventCreated) {
        [attributedString mvc_addTintedForegroundColorAttribute];
        
        if (concreteEvent.refType == OCTRefTypeBranch) {
            [attributedString mvc_addRepositoryLinkAttributeWithName:self.repositoryName referenceName:ReferenceNameWithBranchName(concreteEvent.refName)];
        } else if (concreteEvent.refType == OCTRefTypeTag) {
            [attributedString mvc_addRepositoryLinkAttributeWithName:self.repositoryName referenceName:ReferenceNameWithTagName(concreteEvent.refName)];
        }
    } else if (concreteEvent.eventType == OCTRefEventDeleted) {
        [attributedString insertAttributedString:@" ".mvc_attributedString atIndex:0];
        [attributedString appendAttributedString:@"\n".mvc_attributedString];
        [attributedString mvc_addNormalTitleForegroundColorAttribute];
        [attributedString mvc_addBackgroundColorAttribute];
    }
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_dateAttributedString {
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    
    timeIntervalFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *date = [@"\n" stringByAppendingString:[timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:self.date]];
    
    NSMutableAttributedString *attributedString = date.mvc_attributedString;
    
    [attributedString mvc_addTimeFontAttribute];
    [attributedString mvc_addTimeForegroundColorAttribute];
    [attributedString mvc_addParagraphStyleAttribute];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_pullInfoAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTPullRequestEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    OCTPullRequestEvent *concreteEvent = (OCTPullRequestEvent *)self;
    
    NSString *octicon = [NSString stringWithFormat:@" %@ ", [NSString octicon_iconStringForEnum:OCTIconGitCommit]];
    
    NSString *commits   = concreteEvent.pullRequest.commits > 1 ? @" commits with " : @" commit with ";
    NSString *additions = concreteEvent.pullRequest.additions > 1 ? @" additions and " : @" addition and ";
    NSString *deletions = concreteEvent.pullRequest.deletions > 1 ? @" deletions " : @" deletion ";
    
    [attributedString appendAttributedString:octicon.mvc_attributedString.mvc_addOcticonAttributes.mvc_addParagraphStyleAttribute];
    [attributedString appendAttributedString:@(concreteEvent.pullRequest.commits).stringValue.mvc_attributedString.mvc_addBoldPullInfoFontAttribute.mvc_addPullInfoForegroundColorAttribute];
    [attributedString appendAttributedString:commits.mvc_attributedString.mvc_addNormalPullInfoFontAttribute.mvc_addPullInfoForegroundColorAttribute];
    [attributedString appendAttributedString:@(concreteEvent.pullRequest.additions).stringValue.mvc_attributedString.mvc_addBoldPullInfoFontAttribute.mvc_addPullInfoForegroundColorAttribute];
    [attributedString appendAttributedString:additions.mvc_attributedString.mvc_addNormalPullInfoFontAttribute.mvc_addPullInfoForegroundColorAttribute];
    [attributedString appendAttributedString:@(concreteEvent.pullRequest.deletions).stringValue.mvc_attributedString.mvc_addBoldPullInfoFontAttribute.mvc_addPullInfoForegroundColorAttribute];
    [attributedString appendAttributedString:deletions.mvc_attributedString.mvc_addNormalPullInfoFontAttribute.mvc_addPullInfoForegroundColorAttribute];
    [attributedString mvc_addBackgroundColorAttribute];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_commitCommentEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTCommitCommentEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" commented on commit ".mvc_attributedString.mvc_addBoldTitleAttributes];
    [attributedString appendAttributedString:self.mvc_commentedCommitAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_forkEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTForkEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" forked ".mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_repositoryNameAttributedString];
    [attributedString appendAttributedString:@" to ".mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_forkedRepositoryNameAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_issueCommentEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTIssueCommentEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" commented on issue ".mvc_attributedString.mvc_addBoldTitleAttributes];
    [attributedString appendAttributedString:self.mvc_issueAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_issueEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTIssueEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    OCTIssueEvent *concreteEvent = (OCTIssueEvent *)self;
    
    NSString *action = nil;
    if (concreteEvent.action == OCTIssueActionOpened) {
        action = @"opened";
    } else if (concreteEvent.action == OCTIssueActionClosed) {
        action = @"closed";
    } else if (concreteEvent.action == OCTIssueActionReopened) {
        action = @"reopened";
    }
    
    [attributedString appendAttributedString:[NSString stringWithFormat:@" %@ issue ", action].mvc_attributedString.mvc_addBoldTitleAttributes];
    [attributedString appendAttributedString:self.mvc_issueAttributedString];
    [attributedString appendAttributedString:[@"\n" stringByAppendingString:concreteEvent.issue.title].mvc_attributedString.mvc_addNormalTitleAttributes.mvc_addParagraphStyleAttribute];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_memberEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTMemberEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" added ".mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_memberLoginAttributedString];
    [attributedString appendAttributedString:@" to ".mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_repositoryNameAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_publicEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTPublicEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" open sourced ".mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_repositoryNameAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_pullRequestCommentEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTPullRequestCommentEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" commented on pull request ".mvc_attributedString.mvc_addBoldTitleAttributes];
    [attributedString appendAttributedString:self.mvc_pullRequestAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_pullRequestEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTPullRequestEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    OCTPullRequestEvent *concreteEvent = (OCTPullRequestEvent *)self;
    
    NSString *action = nil;
    if (concreteEvent.action == OCTIssueActionOpened) {
        action = @"opened";
    } else if (concreteEvent.action == OCTIssueActionClosed) {
        action = @"closed";
    } else if (concreteEvent.action == OCTIssueActionReopened) {
        action = @"reopened";
    } else if (concreteEvent.action == OCTIssueActionSynchronized) {
        action = @"synchronized";
    }
    
    [attributedString appendAttributedString:[NSString stringWithFormat:@" %@ pull request ", action].mvc_attributedString.mvc_addBoldTitleAttributes];
    [attributedString appendAttributedString:self.mvc_pullRequestAttributedString];
    [attributedString appendAttributedString:[@"\n" stringByAppendingString:concreteEvent.pullRequest.title].mvc_attributedString.mvc_addNormalTitleAttributes.mvc_addParagraphStyleAttribute];
    [attributedString appendAttributedString:@"\n".mvc_attributedString];
    [attributedString appendAttributedString:self.mvc_pullInfoAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_pushEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTPushEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" pushed to ".mvc_attributedString.mvc_addBoldTitleAttributes];
    [attributedString appendAttributedString:self.mvc_branchNameAttributedString];
    [attributedString appendAttributedString:@" at ".mvc_attributedString.mvc_addBoldTitleAttributes];
    [attributedString appendAttributedString:self.mvc_repositoryNameAttributedString];
    [attributedString appendAttributedString:self.mvc_pushedCommitsAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_refEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTRefEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    OCTRefEvent *concreteEvent = (OCTRefEvent *)self;
    
    NSString *action = nil;
    if (concreteEvent.eventType == OCTRefEventCreated) {
        action = @"created";
    } else if (concreteEvent.eventType == OCTRefEventDeleted) {
        action = @"deleted";
    }
    
    NSString *type = nil;
    if (concreteEvent.refType == OCTRefTypeBranch) {
        type = @"branch";
    } else if (concreteEvent.refType == OCTRefTypeTag) {
        type = @"tag";
    } else if (concreteEvent.refType == OCTRefTypeRepository) {
        type = @"repository";
    }
    
    NSString *at = (concreteEvent.refType == OCTRefTypeBranch || concreteEvent.refType == OCTRefTypeTag ? @" at " : @"");
    
    [attributedString appendAttributedString:[NSString stringWithFormat:@" %@ %@ ", action, type].mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_refNameAttributedString];
    [attributedString appendAttributedString:at.mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_repositoryNameAttributedString];
    
    return attributedString;
}

- (NSMutableAttributedString *)mvc_watchEventAttributedString {
    NSParameterAssert([self isMemberOfClass:[OCTWatchEvent class]]);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:@" starred ".mvc_attributedString.mvc_addNormalTitleAttributes];
    [attributedString appendAttributedString:self.mvc_repositoryNameAttributedString];
    
    return attributedString;
}

#pragma mark - Private

static NSString *ShortSHA(NSString *SHA) {
    NSCParameterAssert(SHA.length > 0);
    return [SHA substringToIndex:7];
}


@end
