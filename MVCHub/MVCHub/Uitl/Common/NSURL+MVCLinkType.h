//
//  NSURL+MVCLinkType.h
//  MVCHub
//
//  Created by daniel on 2016/10/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MVCLinkType) {
    MVCLinkTypeUnknown,
    MVCLinkTypeUser,
    MVCLinkTypeRepository
};

@interface NSURL (MVCLinkType)

@property (nonatomic, assign, readonly) MVCLinkType type;


/**
 Return a GitHub NSURL for login of specified 'user'

 @param login User's login

 @return NSURL
 */
+ (instancetype)mvc_userLinkWithLogin:(NSString *)login;


/**
 Return a GitHub NSURL of repository that specified 'user' owned

 @param name          User's name
 @param referenceName ReferenceName

 @return NSURL
 */
+ (instancetype)mvc_repositoryLinkWithName:(NSString *)name referenceName:(NSString *)referenceName;

- (NSDictionary *)mvc_dictionary;

@end

@interface OCTEvent (MVCLinkType)

- (NSURL *)mvc_Link;

@end
