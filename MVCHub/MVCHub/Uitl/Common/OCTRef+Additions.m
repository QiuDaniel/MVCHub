//
//  OCTRef+Additions.m
//  MVCHub
//
//  Created by daniel on 2016/10/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OCTRef+Additions.h"

static NSString *const RefBranchReferenceNamePrefix = @"refs/heads/";
static NSString *const RefTagReferenceNamePrefix = @"refs/tags/";

@implementation OCTRef (Additions)

NSString *DefaultReferenceName() {
    return [RefBranchReferenceNamePrefix stringByAppendingString:@"master"];
}

NSString *ReferenceNameWithBranchName(NSString *branchName) {
    NSCParameterAssert(branchName.length > 0);
    return [NSString stringWithFormat:@"%@%@", RefBranchReferenceNamePrefix, branchName];
}

NSString *ReferenceNameWithTagName(NSString *tagName) {
    NSCParameterAssert(tagName.length > 0);
    return [NSString stringWithFormat:@"%@%@", RefTagReferenceNamePrefix, tagName];
}

@end
