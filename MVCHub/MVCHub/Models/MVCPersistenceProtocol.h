//
//  MVCPersistenceProtocol.h
//  MVCHub
//
//  Created by daniel on 2016/10/16.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MVCPersistenceProtocol <NSObject>

@required

- (BOOL)mvc_saveOrUpdate;
- (BOOL)mvc_delete;

@end
