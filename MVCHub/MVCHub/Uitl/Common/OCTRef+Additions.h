//
//  OCTRef+Additions.h
//  MVCHub
//
//  Created by daniel on 2016/10/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTRef (Additions)

NSString *DefaultReferenceName();
NSString *ReferenceNameWithBranchName(NSString *branchName);
NSString *ReferenceNameWithTagName(NSString *tagName);

@end
