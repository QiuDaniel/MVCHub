//
//  MVCUtil.h
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVCUtil : NSObject

@end

@interface NSString (Util)

- (BOOL)isExist;
- (BOOL)isImage;
- (BOOL)isMarkdown;

- (NSString *)firstLetter;
+ (NSString *)summaryReadmeHTMLFromReadmeHTML:(NSString *)readmeHTML;

@end

@interface UIColor (Util)

/// Generating a new image by the color.
///
/// Returns a new image.
- (UIImage *)color2Image;
- (UIImage *)color2ImageSized:(CGSize)size;

@end

@interface NSMutableArray (MVCSafeAdditions)

- (void)mvc_addObject:(id)object;

@end
