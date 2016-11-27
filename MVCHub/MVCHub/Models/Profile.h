//
//  Profile.h
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject
@property (nonatomic, copy, readwrite) NSString *company, *location, *email, *blog;
@end
