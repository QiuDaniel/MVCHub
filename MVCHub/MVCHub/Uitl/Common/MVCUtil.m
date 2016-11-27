//
//  MVCUtil.m
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "MVCUtil.h"

@implementation MVCUtil

@end

@implementation NSString (Util)

- (BOOL)isExist {
    return self && ![self isEqualToString:@""];
}

- (BOOL)isImage {
    if (!self.isExist) return NO;
    
    NSArray *imageExtensions = @[ @".png", @".gif", @".jpg", @".jpeg" ];
    for (NSString *extension in imageExtensions) {
        if ([self.lowercaseString hasSuffix:extension]) return YES;
    }
    
    return NO;
}

- (BOOL)isMarkdown {
    if (!self.isExist) return NO;
    
    NSArray *markdownExtensions = @[ @".md", @".mkdn", @".mdwn", @".mdown", @".markdown", @".mkd", @".mkdown", @".ron" ];
    for (NSString *extension in markdownExtensions) {
        if ([self.lowercaseString hasSuffix:extension]) return YES;
    }
    
    return NO;
}

- (NSString *)firstLetter {
    return [[self substringToIndex:1] uppercaseString];
}

+ (NSString *)summaryReadmeHTMLFromReadmeHTML:(NSString *)readmeHTML {
    __block NSString *summaryReadmeHTML = kMVCReadmeCSSStyle;
    
    NSError *error = nil;
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithString:readmeHTML encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) DebugLogError(error);
    
    NSString *XPath = @"//article/*";
    [document enumerateElementsWithXPath:XPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        if (idx < 3) {
            summaryReadmeHTML = [summaryReadmeHTML stringByAppendingString:element.description];
        }
    }];
    
    if ([summaryReadmeHTML isEqualToString:kMVCReadmeCSSStyle]) {
        NSString *CSS = @"div#readme";
        [document enumerateElementsWithCSS:CSS usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            if (idx < 3) {
                summaryReadmeHTML = [summaryReadmeHTML stringByAppendingString:element.description];
            }
        }];
    }
    
    return summaryReadmeHTML;
}

@end

@implementation UIColor (Util)

- (UIImage *)color2Image {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)color2ImageSized:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation NSMutableArray (MVCSafeAdditions)

- (void)mvc_addObject:(id)object {
    if (!object) return;
    [self addObject:object];
}

@end
