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

@interface RootTabViewController ()

@end

@implementation RootTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewContrllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private_Method

- (void)setupViewContrllers {
    News_RootViewController *news = [[News_RootViewController alloc] init];
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
//        UIImage *selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
//                                                      [tabBarItemImages objectAtIndex:index]]];
//        UIImage *unselectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
//                                                        [tabBarItemImages objectAtIndex:index]]];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
