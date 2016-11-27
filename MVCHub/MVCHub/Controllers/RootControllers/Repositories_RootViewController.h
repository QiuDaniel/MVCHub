//
//  Repositories_RootViewController.h
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, Repositories_RootViewControllerType) {
    Repositories_RootViewControllerTypeOwned,
    Repositories_RootViewControllerTypeStarred
};

@interface Repositories_RootViewController : BaseViewController

+ (instancetype)newRepositoriesVCWithType:(Repositories_RootViewControllerType)type;

@end
