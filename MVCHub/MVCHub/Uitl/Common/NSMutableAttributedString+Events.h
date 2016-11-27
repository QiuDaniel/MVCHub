//
//  NSMutableAttributedString+Events.h
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

// Font

#define EventsNormalTitleFont    [UIFont systemFontOfSize:15]
#define EventsBoldTitleFont      [UIFont boldSystemFontOfSize:16]
#define EventsOcticonFont        [UIFont fontWithName:kOcticonsFamilyName size:16]
#define EventsTimeFont           [UIFont systemFontOfSize:13]
#define EventsNormalPullInfoFont [UIFont systemFontOfSize:12]
#define EventsBoldPullInfoFont   [UIFont boldSystemFontOfSize:12]

// Foreground Color

#define EventsTintedForegroundColor     [UIColor colorWithHexString:@"0x4078c0"]
#define EventsNormalTitleForegroundColor    [UIColor colorWithHexString:@"0x666666"]
#define EventsBoldTitleForegroundColor      [UIColor colorWithHexString:@"0x333333"]
#define EventsTimeForegroundColor            [UIColor colorWithHexString:@"0xbbbbbb"]
#define EventsPullInfoForegroundColor        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

// Paragraph Style

#define EventsParagraphStyle ({ \
NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init]; \
paragraphStyle.paragraphSpacingBefore = 5; \
paragraphStyle; \
})

extern NSString *const LinkAttributeName;


@interface NSString (Events)

- (NSMutableAttributedString *)mvc_attributedString;

@end

@interface NSMutableAttributedString (Events)

#pragma mark - Font

- (NSMutableAttributedString *)mvc_addNormalTitleFontAttribute;
- (NSMutableAttributedString *)mvc_addBoldTitleFontAttribute;
- (NSMutableAttributedString *)mvc_addOcticonFontAttribute;
- (NSMutableAttributedString *)mvc_addTimeFontAttribute;
- (NSMutableAttributedString *)mvc_addNormalPullInfoFontAttribute;
- (NSMutableAttributedString *)mvc_addBoldPullInfoFontAttribute;


#pragma mark - Foreground Color

- (NSMutableAttributedString *)mvc_addTintedForegroundColorAttribute;
- (NSMutableAttributedString *)mvc_addNormalTitleForegroundColorAttribute;
- (NSMutableAttributedString *)mvc_addBoldTitleForegroundColorAttribute;
- (NSMutableAttributedString *)mvc_addTimeForegroundColorAttribute;
- (NSMutableAttributedString *)mvc_addPullInfoForegroundColorAttribute;

#pragma mark - Background Color

- (NSMutableAttributedString *)mvc_addBackgroundColorAttribute;

#pragma mark - Paragraph Style

- (NSMutableAttributedString *)mvc_addParagraphStyleAttribute;

#pragma mark - Link

- (NSMutableAttributedString *)mvc_addUserLinkAttribute;
- (NSMutableAttributedString *)mvc_addRepositoryLinkAttributeWithName:(NSString *)name referenceName:(NSString *)referenceName;
- (NSMutableAttributedString *)mvc_addHTMLURLAttribute:(NSURL *)HTMLURL;

#pragma mark - Highlight

- (NSMutableAttributedString *)mvc_addHighlightAttribute;

#pragma mark - Combination

- (NSMutableAttributedString *)mvc_addOcticonAttributes;
- (NSMutableAttributedString *)mvc_addNormalTitleAttributes;
- (NSMutableAttributedString *)mvc_addBoldTitleAttributes;

@end
