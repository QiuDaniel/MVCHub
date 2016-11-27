//
//  OCTEvent+MVCPersistence.m
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OCTEvent+MVCPersistence.h"

@implementation OCTEvent (MVCPersistence)

+ (BOOL)mvc_saveUserReceivedEvents:(NSArray *)events {
    return [NSKeyedArchiver archiveRootObject:events toFile:[self receivedEventsPersistencePath]];
}
+ (BOOL)mvc_saveUserPerformedEvents:(NSArray *)events {
    return [NSKeyedArchiver archiveRootObject:events toFile:[self performedEventsPersistencePath]];
}

+ (NSArray *)mvc_fetchUserReceivedEvents {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self receivedEventsPersistencePath]];
}
+ (NSArray *)mvc_fetchUserPerformedEvents {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self performedEventsPersistencePath]];
}

#pragma mark - Private Methods

+ (NSString *)persistenceDirectory {
    NSString *path = [NSString stringWithFormat:@"%@/Persistence/%@", MVC_DOCUMENT_DIRECTORY, [OCTUser mvc_currentUser].login];
    
    BOOL isDirectory;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        if (success) {
            [self addSkipBackupAttributeToItemAtPath:path];
        } else {
            DebugLog(@"Error:%@",error);
        }
    }
    
    return path;
}

+ (NSString *)receivedEventsPersistencePath {
    return [[self persistenceDirectory] stringByAppendingPathComponent:@"ReceivedEvents"];
}

+ (NSString *)performedEventsPersistencePath {
    return [[self persistenceDirectory] stringByAppendingPathComponent:@"PerformedEvents"];
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    
    assert([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) DebugLog(@"Error:%@",error);
    
    return success;

}
@end
