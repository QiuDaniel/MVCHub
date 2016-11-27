//
//  AppDelegate.m
//  MVCHub
//
//  Created by daniel on 2016/10/13.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import "RootTabViewController.h"
#import "Login.h"


@interface AppDelegate ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self configureFMDB];
    [self configureReachability];
    [self configureUMengSoical];
    
    self.window = [[UIWindow alloc] initWithFrame:kScreen_Bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    // Override point for customization after application launch.
    [self customizeInterface];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self setupLoginViewController];
    
    // Save the application version info
    [[NSUserDefaults standardUserDefaults] setValue:kVersion_MVCHub forKey:kVersionKey_MVCHub];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - publicMethods

- (void)setupLoginViewController {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.window setRootViewController:[[BaseNavigationController alloc] initWithRootViewController:loginVC]];
}

- (void)setupTabViewController {
    RootTabViewController *rootVC = [[RootTabViewController alloc] init];
    rootVC.tabBar.translucent = YES;
    
    [self.window setRootViewController:rootVC];
}

#pragma mark - privateMethods

/**
 设置Nav的背景色和title色
 */
- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    // 0x2F434F
//    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:[ UIColor colorWithRed:(48 - 40) / 215.0 green:(67 - 40) / 215.0 blue:(78 - 40) / 215.0 alpha:1]] forBarMetrics:UIBarMetricsDefault];
    navigationBarAppearance.barTintColor = [UIColor colorWithHexString:@"0x2f434f"];
    navigationBarAppearance.barStyle = UIBarStyleBlack;
    [navigationBarAppearance setTintColor:[UIColor whiteColor]]; // 设置返回箭头的颜色
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName:[UIFont boldSystemFontOfSize:kNavTitleFontSize],
                                     NSForegroundColorAttributeName:[UIColor whiteColor]
                                     };
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    [[UITextField appearance] setTintColor:[UIColor blueColor]];//设置UITextField的光标颜色
    [[UITextView appearance] setTintColor:[UIColor blueColor]];//设置UITextView的光标颜色
    [[UISegmentedControl appearance] setTintColor:[UIColor whiteColor]];
    
}

- (void)configureFMDB {
    [[FMDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *version = [[NSUserDefaults standardUserDefaults] valueForKey:kVersionKey_MVCHub];
        if (![version isEqualToString:kVersion_MVCHub]) {
            if (version == nil) {
                [SSKeychain deleteAccessToken];
                
                NSString *path = [[NSBundle mainBundle] pathForResource:@"update_v1_2_0" ofType:@"sql"];
                NSString *sql = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                if (![db executeStatements:sql]) {
                    DebugLogLastError(db);
                }
            }
        }
    }];
}

- (void)configureReachability {
    self.reachability = Reachability.reachabilityForInternetConnection;
    RAC(self, networkStatus) = [[[[[NSNotificationCenter defaultCenter]
                                   rac_addObserverForName:kReachabilityChangedNotification
                                   object:nil]
                                  map:^(NSNotification *notification) {
        return @([notification.object currentReachabilityStatus]);
    }]
                                 startWith:@(self.reachability.currentReachabilityStatus)] distinctUntilChanged];
    
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        [self.reachability startNotifier];
    });
}

- (void)configureUMengSoical {
    [UMSocialData setAppKey:kUMengAPPKey];
    [UMSocialWechatHandler setWXAppId:kWXAPPID appSecret:kWXAPPSecret url:kUMengShareURL];
    //[UMSocialConfig hiddenNotInstallPlatforms:@[ UMShareToWechatSession, UMShareToWechatTimeline]];
}
@end
