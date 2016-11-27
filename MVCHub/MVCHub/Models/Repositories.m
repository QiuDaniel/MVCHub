//
//  Repositories.m
//  MVCHub
//
//  Created by daniel on 2016/11/8.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Repositories.h"
#import "TTTTimeIntervalFormatter.h"

@implementation Repositories

- (instancetype)initWithRepository:(OCTRepository *)repository {
    self = [super init];
    if (self) {
        self.repository = repository;
        self.language = repository.language ?: @"";
        
        CGFloat height = 0;
        if (self.repository.repoDescription.length > 0) {
            NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:15.0] };
            
            CGFloat width = kScreen_Width - 38 -8;
            if (self.options & ReposViewModelOptionsSectionIndex) {
                width -= 15;
            }
            
            CGRect rect = [self.repository.repoDescription boundingRectWithSize:CGSizeMake(width, 0)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:attributes
                                                                        context:nil];
            height = MIN(ceil(rect.size.height), 18 * 3);
        }
        self.height = 8 + 21 + 5 + height + 5 + 15 + 8 + 1;
    }
    return self;
}

- (NSAttributedString *)name {
    if (!_name) {
        if (self.options & ReposViewModelOptionsShowOwnerLogin) {
            NSString *uniqueName = [NSString stringWithFormat:@"%@/%@", self.repository.ownerLogin, self.repository.name];
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:uniqueName];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0x4183C4"] range:[uniqueName rangeOfString:uniqueName]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:[uniqueName rangeOfString:[self.repository.ownerLogin stringByAppendingString:@"/"]]];
            
            _name = [attributedString copy];
        } else {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.repository.name];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0x4183C4"] range:[self.repository.name rangeOfString:self.repository.name]];
            _name = [attributedString copy];
        }
    }
    return _name;
}

- (NSAttributedString *)repoDescription {
    if (!_repoDescription) {
        NSMutableAttributedString *attributedString = nil;
        
        if (self.repository.repoDescription) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:self.repository.repoDescription];
            for (NSDictionary *textMatche in self.repository.textMatches) {
                if ([textMatche[@"property"] isEqualToString:@"description"]) {
                    for (NSDictionary *matche in textMatche[@"matches"]) {
                        NSUInteger loc = [[matche[@"indices"] firstObject] unsignedIntegerValue];
                        NSUInteger len = [[matche[@"indices"] lastObject] unsignedIntegerValue] - loc ;
                        [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:140 / 255.0 alpha:0.5] range:NSMakeRange(loc, len)];
                    }
                }
            }
        }
        
        _repoDescription = attributedString.copy;
        _repoDescription = [_repoDescription attributedSubstringFromRange:NSMakeRange(0, MIN(150, _repoDescription.length))];
    }
    return _repoDescription;
}

- (NSString *)updateTime {
    if (!_updateTime) {
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        timeIntervalFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _updateTime = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:self.repository.dateUpdated].copy;
    }
    return _updateTime;
}
@end
