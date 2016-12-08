//
//  BaseViewController.m
//  MVCHub
//
//  Created by daniel on 16/10/1.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"
#import "Login.h"
#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "RootTabViewController.h"
#import "LoadingTitleView.h"

#pragma mark - UIViewContrller (Dismiss)
@interface UIViewController (Dismiss)
- (void)dismissModalVC;
@end
@implementation UIViewController (Dismiss)

- (void)dismissModalVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma mark - BaseViewController
@interface BaseViewController ()
//@property (nonatomic, strong) PopMenu *myPopMenu;

@end

@implementation BaseViewController

#pragma mark - Init

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait && !([self supportedInterfaceOrientations] & UIInterfaceOrientationLandscapeLeft)) {
    }
    [self setupNavBtn];
    [self judgetitleView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private Methods

- (void)judgetitleView {
    UIView *titleView = self.navigationItem.titleView;
    
    LoadingTitleView *loadingTitleView = [[LoadingTitleView alloc] initWithFrame:CGRectMake(0, 0, 106, 44)];
    self.doubleTitleView = [[DoubleTitleView alloc] initWithFrame:CGRectMake(0, 0, 106, 44)];
    @weakify(self)
    RAC(self.navigationItem, titleView) = [[RACObserve(self, titleViewType) distinctUntilChanged] map:^(NSNumber *value) {
        @strongify(self)
        TitleViewType titleViewType = value.unsignedIntegerValue;
        switch (titleViewType) {
            case TitleViewTypeDefault:
                return titleView;
            case TitleViewTypeDoubleTitle:
                return (UIView *)self.doubleTitleView;
            case TitleViewTypeLoadingTitle:
                return (UIView *)loadingTitleView;
        }
    }];
}

#pragma mark - Public Methods

- (void)setupNavBtn {
    // 使push进入的页面的返回键不带文字
    UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] init];
    backBtnItem.title = @"";
    self.navigationItem.backBarButtonItem = backBtnItem;
}


- (void)tabbarItemClicked {
    DebugLog(@"\ntabBarItemClicked: %@",NSStringFromClass([self class]));
}

- (void)logoutToLoginVC {
    [Login logOut];
    [MVCSharedAppDelegate setupLoginViewController];
}


- (void)addImageBarButtonWithImage:(UIImage *)image button:(UIButton *)aBtn action:(SEL)action isRight:(BOOL)isR
{
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    aBtn.frame=frame;
    [aBtn setImage:image forState:UIControlStateNormal];
    [aBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aBtn];
    
    if (isR)
    {
        [self.navigationItem setRightBarButtonItem:barButtonItem];
    }else
    {
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
    }
}


+ (UIViewController *)presentingVC{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[RootTabViewController class]]) {
        result = [(RootTabViewController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

+ (void)presentVC:(UIViewController *)viewController{
    if (!viewController) {
        return;
    }
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:viewController];
    if (!viewController.navigationItem.leftBarButtonItem) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissModalVC)];
    }
    [[self presentingVC] presentViewController:nav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
