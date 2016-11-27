//
//  BaseViewController.h
//  NetMananerEngineer
//
//  Created by daniel on 16/7/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoubleTitleView.h"

typedef NS_ENUM(NSUInteger, TitleViewType) {
    TitleViewTypeDefault,
    TitleViewTypeDoubleTitle,
    TitleViewTypeLoadingTitle
};

@interface BaseViewController : UIViewController
@property (nonatomic, strong) DoubleTitleView *doubleTitleView;
@property(nonatomic, assign) TitleViewType titleViewType;

- (instancetype)initWithParams:(NSDictionary *)params;
- (void)tabbarItemClicked;
- (void)logoutToLoginVC;
//- (void)setupPopMenu;
- (void)setupNavBtn;
- (void)addImageBarButtonWithImage:(UIImage *)image button:(UIButton*)aBtn action:(SEL)action isRight:(BOOL)isR;
//- (void)openRightMenu:(id)sender;

+ (UIViewController *)presentingVC;
+ (void)presentVC:(UIViewController *)viewController;

@end
