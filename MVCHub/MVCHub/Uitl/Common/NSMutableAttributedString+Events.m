//
//  NSMutableAttributedString+Events.m
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "NSMutableAttributedString+Events.h"

NSString *const LinkAttributeName = @"LinkAttributeName";

@implementation NSString (Events)

- (NSMutableAttributedString *)mvc_attributedString {
    return [[NSMutableAttributedString alloc] initWithString:self];
}

@end

@implementation NSMutableAttributedString (Events)

#pragma mark - Font

- (NSMutableAttributedString *)mvc_addNormalTitleFontAttribute {
    [self addAttribute:NSFontAttributeName value:EventsNormalTitleFont range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addBoldTitleFontAttribute {
    [self addAttribute:NSFontAttributeName value:EventsBoldTitleFont range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addOcticonFontAttribute {
    [self addAttribute:NSFontAttributeName value:EventsOcticonFont range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addTimeFontAttribute {
    [self addAttribute:NSFontAttributeName value:EventsTimeFont range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addNormalPullInfoFontAttribute {
    [self addAttribute:NSFontAttributeName value:EventsNormalPullInfoFont range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addBoldPullInfoFontAttribute {
    [self addAttribute:NSFontAttributeName value:EventsBoldPullInfoFont range:[self.string rangeOfString:self.string]];
    return self;
}

#pragma mark - Foreground Color

- (NSMutableAttributedString *)mvc_addTintedForegroundColorAttribute {
    [self addAttribute:NSForegroundColorAttributeName value:EventsTintedForegroundColor range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addNormalTitleForegroundColorAttribute {
    [self addAttribute:NSForegroundColorAttributeName value:EventsNormalTitleForegroundColor range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addBoldTitleForegroundColorAttribute {
    [self addAttribute:NSForegroundColorAttributeName value:EventsBoldTitleForegroundColor range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addTimeForegroundColorAttribute {
    [self addAttribute:NSForegroundColorAttributeName value:EventsTimeForegroundColor range:[self.string rangeOfString:self.string]];
    return self;
}

- (NSMutableAttributedString *)mvc_addPullInfoForegroundColorAttribute {
    [self addAttribute:NSForegroundColorAttributeName value:EventsPullInfoForegroundColor range:[self.string rangeOfString:self.string]];
    return self;
}

#pragma mark - Background Color

- (NSMutableAttributedString *)mvc_addBackgroundColorAttribute {
    [self addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithHexString:@"0xe8f1f6"] range:[self.string rangeOfString:self.string]];
    return self;
}

#pragma mark - Paragraph Style

- (NSMutableAttributedString *)mvc_addParagraphStyleAttribute {
    if (self.length > 0) {
        [self addAttribute:NSParagraphStyleAttributeName value:EventsParagraphStyle range:NSMakeRange(0, MIN(2, self.length))];
    }
    return self;
}

#pragma mark - Link

- (NSMutableAttributedString *)mvc_addUserLinkAttribute {
    [self addAttribute:LinkAttributeName value:[NSURL mvc_userLinkWithLogin:self.string] range:[self.string rangeOfString:self.string]];
    [self mvc_addHighlightAttribute];
    return self;
}

- (NSMutableAttributedString *)mvc_addRepositoryLinkAttributeWithName:(NSString *)name referenceName:(NSString *)referenceName {
    [self addAttribute:LinkAttributeName value:[NSURL mvc_repositoryLinkWithName:name referenceName:referenceName] range:[self.string rangeOfString:self.string]];
    [self mvc_addHighlightAttribute];
    return self;
}

- (NSMutableAttributedString *)mvc_addHTMLURLAttribute:(NSURL *)HTMLURL {
    [self addAttribute:LinkAttributeName value:HTMLURL range:[self.string rangeOfString:self.string]];
    [self mvc_addHighlightAttribute];
    return self;
}

#pragma mark - Highlight

- (NSMutableAttributedString *)mvc_addHighlightAttribute {
    YYTextBorder *highlightBorder = [[YYTextBorder alloc] init];
    
    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    highlightBorder.cornerRadius = 3;
    //    highlightBorder.fillColor = HexRGB(0xbfdffe);
    highlightBorder.fillColor = [UIColor colorWithHexString:@"0xD9D9D9"];
    
    YYTextHighlight *highlight = [[YYTextHighlight alloc] init];
    [highlight setBackgroundBorder:highlightBorder];
    
    [self setTextHighlight:highlight range:[self.string rangeOfString:self.string]];
    
    return self;
}

#pragma mark - Combination

- (NSMutableAttributedString *)mvc_addOcticonAttributes {
    return [[self mvc_addOcticonFontAttribute] mvc_addTimeForegroundColorAttribute];
}

- (NSMutableAttributedString *)mvc_addNormalTitleAttributes {
    return [[self mvc_addNormalTitleFontAttribute] mvc_addNormalTitleForegroundColorAttribute];
}

- (NSMutableAttributedString *)mvc_addBoldTitleAttributes {
    return [[self mvc_addBoldTitleFontAttribute] mvc_addBoldTitleForegroundColorAttribute];
}


@end
