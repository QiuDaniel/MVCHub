//
//  AppDelegate.h
//  MVCHub
//
//  Created by daniel on 2016/10/13.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoginType) {
    LoginTypeFromLoginVC,
    LoginTypeFromCache
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) NetworkStatus networkStatus;

- (void)setupLoginViewController;
- (void)setupTabViewControllerFormLoginType:(LoginType)loginType;
@end

