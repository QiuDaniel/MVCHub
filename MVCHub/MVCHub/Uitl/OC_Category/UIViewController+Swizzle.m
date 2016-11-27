//
//  UIViewController+Swizzle.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import "ObjcRuntime.h"
#import "RDVTabBarController.h"


@implementation UIViewController (Swizzle)
- (void)customViewDidAppear:(BOOL)animated{
    if ([NSStringFromClass([self class]) rangeOfString:@"_RootViewController"].location != NSNotFound) {
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
        DebugLog(@"setTabBarHidden:NO --- customViewDidAppear : %@", NSStringFromClass([self class]));
    }
    [self customViewDidAppear:animated];
}

- (void)customViewWillDisappear:(BOOL)animated{
//    返回按钮
    if (!self.navigationItem.backBarButtonItem
        && self.navigationController.viewControllers.count > 1) {//设置返回按钮(backBarButtonItem的图片不能设置；如果用leftBarButtonItem属性，则iOS7自带的滑动返回功能会失效)
        self.navigationItem.backBarButtonItem = [self backButton];
    }
    [self customViewWillDisappear:animated];
}

- (void)customviewWillAppear:(BOOL)animated{
    if ([[self.navigationController childViewControllers] count] > 1) {
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        DebugLog(@"setTabBarHidden:YES --- customviewWillAppear : %@", NSStringFromClass([self class]));
    }
    [self customviewWillAppear:animated];
}


#pragma mark BackBtn M
- (UIBarButtonItem *)backButton{
    NSDictionary*textAttributes;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    temporaryBarButtonItem.target = self;
    if ([temporaryBarButtonItem respondsToSelector:@selector(setTitleTextAttributes:forState:)]){
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:kBackButtonFontSize],
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    }
    temporaryBarButtonItem.action = @selector(goBack_Swizzle);
    return temporaryBarButtonItem;
}

- (void)goBack_Swizzle
{
    [self.navigationController popViewControllerAnimated:YES];
}

+ (void)load{
    swizzleAllViewController();
}
@end

void swizzleAllViewController()
{
    Swizzle([UIViewController class], @selector(viewDidAppear:), @selector(customViewDidAppear:));
    Swizzle([UIViewController class], @selector(viewWillDisappear:), @selector(customViewWillDisappear:));
    Swizzle([UIViewController class], @selector(viewWillAppear:), @selector(customviewWillAppear:));
}