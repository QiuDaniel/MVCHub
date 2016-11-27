//
//  FMDatabaseQueue+MVCHelper.m
//  MVCHub
//
//  Created by daniel on 2016/10/15.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "FMDatabaseQueue+MVCHelper.h"

@implementation FMDatabaseQueue (MVCHelper)

+ (instancetype)sharedInstance {
    static FMDatabaseQueue *databaseQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:MVC_FMDB_PATH];
    });
    return databaseQueue;
}

@end
