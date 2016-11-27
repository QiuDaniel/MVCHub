//
//  TrendingReposViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/19.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "TrendingReposViewController.h"
#import "TrendingViewController.h"
#import "LanguageViewController.h"

@interface TrendingReposViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *contentView, *wrapperView;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, copy) NSDictionary *language;

@end

@implementation TrendingReposViewController

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        NSDictionary *language = (NSDictionary *)[[YYCache sharedCache] objectForKey:TrendingReposLanguageCacheKey];
        self.language = language ?: @{
                                      @"name":@"All languages",
                                      @"slug":@"",
                                      };
        RAC(self, title) = [RACObserve(self, language) map:^(NSDictionary *language) {
            return language[@"name"];
        }];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //[self setupNavBtn];
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.wrapperView];
    [self.wrapperView addSubview:self.segmentedControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupSegmentedViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)setupSegmentedViewController {
    TrendingViewController *dailyViewController = [[TrendingViewController alloc] initWithParams:@{ @"since":@{ @"name": @"Today", @"slug":@"daily"}, @"language":self.language }];
    TrendingViewController *weeklyViewController = [[TrendingViewController alloc] initWithParams:@{ @"since":@{ @"name": @"This week", @"slug":@"weekly"}, @"language":self.language }];
    TrendingViewController *monthlyViewController = [[TrendingViewController alloc] initWithParams:@{ @"since":@{ @"name": @"This month", @"slug":@"monthly"}, @"language":self.language }];
    
    self.viewControllers = @[ dailyViewController, weeklyViewController, monthlyViewController];
    
    for (UIViewController *viewController in self.viewControllers) {
        [self addChildViewController:viewController];
    }
    
    dailyViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:dailyViewController.view];
    self.currentViewController = dailyViewController;
}

#pragma mark - Overwritten Method
- (void)setupNavBtn {
    [super setupNavBtn];
    [self addImageBarButtonWithImage:[UIImage
                                      octicon_imageWithIcon:@"Gear"
                                      backgroundColor:[UIColor clearColor]
                                      iconColor:[UIColor  whiteColor]
                                      iconScale:1
                                      andSize:CGSizeMake(22, 22)]
                              button:[UIButton new]
                              action:@selector(chooseLanguage)
                             isRight:YES];
}

#pragma mark - Response Event
- (void)chooseLanguage {
    LanguageViewController *languageVC = [[LanguageViewController alloc] initWithParams:@{ @"language":self.language ?: @{} }];
    @weakify(self)
    languageVC.callback = ^(NSDictionary *language) {
        @strongify(self)
        self.language = language;
        [[YYCache sharedCache] setObject:language forKey:TrendingReposLanguageCacheKey withBlock:nil];
    };
    [self.navigationController pushViewController:languageVC animated:YES];
}

- (void)didClicksegmentedControlAction:(UISegmentedControl *)segmentedControl {
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    UIViewController *toViewController = self.viewControllers[selectedSegmentIndex];
    toViewController.view.frame = self.contentView.bounds;
    @weakify(self)
    [self transitionFromViewController:self.currentViewController
                      toViewController:toViewController
                              duration:0
                               options:0
                            animations:nil
                            completion:^(BOOL finished) {
                                @strongify(self)
                                self.currentViewController = toViewController;
                      }];
}
#pragma mark - Getter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = ({
            UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.backgroundColor = [UIColor clearColor];
            view;
        });
    }
    return _contentView;
}

- (UIView *)wrapperView {
    if (!_wrapperView) {
        _wrapperView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 45)];
            view.backgroundColor = [UIColor whiteColor];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            UIView *bottomBorder = [view createViewBackedBottomBorderWithHeight:kMVC_1PX_WIDTH andColor:[UIColor colorWithHexString:@"0xC8C7CC"]];
            bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [view addSubview:bottomBorder];
            view;
        });
        
    }
    return _wrapperView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = ({
            UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[@"Daily", @"Weekly", @"Monthly"]];
            control.frame = CGRectMake(10, 8, CGRectGetWidth(self.view.frame) - 10 * 2, 29);
            control.selectedSegmentIndex = 0;
            control.tintColor = [UIColor colorWithHexString:@"0x4183C4"];
            control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [control addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
            control;
        });
    }
    
    return _segmentedControl;
}
@end
