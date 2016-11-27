//
//  Explore.h
//  MVCHub
//
//  Created by daniel on 2016/11/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Explore : NSObject

@property (nonatomic, strong) OCTObject *object;

@property (nonatomic, copy) NSURL *ownerAvatarURL;
@property (nonatomic, copy) NSString *name;

- (instancetype)initWithObject:(id)object;

@end
