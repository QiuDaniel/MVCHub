//
//  OCTEvent+MVCPersistence.h
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <OctoKit/OctoKit.h>

@interface OCTEvent (MVCPersistence)

+ (BOOL)mvc_saveUserReceivedEvents:(NSArray *)events;
+ (BOOL)mvc_saveUserPerformedEvents:(NSArray *)events;

+ (NSArray *)mvc_fetchUserReceivedEvents;
+ (NSArray *)mvc_fetchUserPerformedEvents;

@end
