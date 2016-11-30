//
//  RootTabViewController.m
//  NetMananerEngineer
//
//  Created by daniel on 16/7/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RootTabViewController.h"
#import "News_RootViewController.h"
#import "Repositories_RootViewController.h"
#import "Explore_RootViewController.h"
#import "Profile_RootViewController.h"
#import "RDVTabBarItem.h"
#import "BaseNavigationController.h"
#import "RKSwipeBetweenViewControllers.h"
#import "Login.h"
#import "CBZSplashView.h"

static NSString *const kLaunchColor = @"0x2f434f";

@interface RootTabViewController ()

@property (nonatomic, strong) CBZSplashView *splashView;
@property (nonatomic, assign) LoginType type;

@end

@implementation RootTabViewController

#pragma mark - Init
-(instancetype)initWithLoginType:(LoginType)loginType {
    self = [super init];
    if (self) {
        self.type = loginType;
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == LoginTypeFromCache) {
        [self.view addSubview:self.splashView];
    }
    [self setupViewContrllers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.splashView startAnimation];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private_Method

- (void)setupViewContrllers {
    News_RootViewController *news = [[News_RootViewController alloc] initWithParams:@{ @"user":[Login curLoginUser], @"type":@(0)} ];
    BaseNavigationController *nav_news = [[BaseNavigationController alloc] initWithRootViewController:news];
    RKSwipeBetweenViewControllers *nav_repo = [RKSwipeBetweenViewControllers newSwipeBetweenViewControllers];
    [nav_repo.viewControllerArray addObjectsFromArray:@[
                                                        [Repositories_RootViewController newRepositoriesVCWithType:Repositories_RootViewControllerTypeOwned],
                                                        [Repositories_RootViewController newRepositoriesVCWithType:Repositories_RootViewControllerTypeStarred]
                                                        ]];
    nav_repo.buttonText = @[@"Owned", @"Starred"];
//    Repositories_RootViewController *repo = [[Repositories_RootViewController alloc] init];
//    BaseNavigationController *nav_repo = [[BaseNavigationController alloc] initWithRootViewController:repo];
    Explore_RootViewController *explore = [[Explore_RootViewController alloc] init];
    BaseNavigationController *nav_explore = [[BaseNavigationController alloc] initWithRootViewController:explore];
    Profile_RootViewController *profile = [[Profile_RootViewController alloc] init];
    BaseNavigationController *nav_profile = [[BaseNavigationController alloc] initWithRootViewController:profile];
    [self setViewControllers:@[nav_news, nav_repo, nav_explore, nav_profile]];
    [self customizeTabBarForController];
    self.delegate = self;
}

- (void)customizeTabBarForController {
    UIImage *backgroundImage = [UIImage imageNamed:@"tabbar_background"];
    NSArray *tabBarItemImages = @[@"Rss", @"Repo", @"Search", @"Person"];
    NSArray *tabBarItemTitles = @[@"News", @"Repositories", @"Explore", @"Profile"];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        item.titlePositionAdjustment = UIOffsetMake(0, 3);
        [item setBackgroundSelectedImage:backgroundImage withUnselectedImage:backgroundImage];
        
        UIImage *selectedImage = [UIImage octicon_imageWithIcon:tabBarItemImages[index] backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithHexString:@"0x4183C4"] iconScale:1 andSize:CGSizeMake(25, 25)];
        UIImage *unselectedImage = [UIImage octicon_imageWithIcon:tabBarItemImages[index] backgroundColor:[UIColor clearColor] iconColor:[UIColor lightGrayColor] iconScale:1 andSize:CGSizeMake(25, 25)];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        [item setTitle:[tabBarItemTitles objectAtIndex:index]];
        index ++;
    }
}

#pragma mark - RDVTabBarControllerDelegate
- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedViewController !=viewController) {
        return YES;
    }
    if (![viewController isKindOfClass:[UINavigationController class]]) {
        return  YES;
    }
    UINavigationController *nav = (UINavigationController *)viewController;
    if (nav.topViewController != nav.viewControllers[0]) {
        return YES;
    }
    
    if ([nav.topViewController isKindOfClass:[BaseViewController class]]) {
        BaseViewController *rootVC = (BaseViewController *)nav.topViewController;
        [rootVC tabbarItemClicked];
    }
    return YES;
}

#pragma mark - Getter
- (CBZSplashView *)splashView {
    if (!_splashView) {
        _splashView = ({
            CBZSplashView *view = [CBZSplashView splashViewWithIcon:[UIImage imageNamed:@"icon4splash"] backgroundColor:[UIColor colorWithHexString:kLaunchColor]];
            view.animationDuration = 1.4;
            view;
        });
    }
    return _splashView;
}
@end
