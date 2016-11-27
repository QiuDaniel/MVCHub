//
//  CountryAndLanguageViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "CountryAndLanguageViewController.h"
#import "CountryViewController.h"
#import "LanguageViewController.h"

@interface CountryAndLanguageViewController ()

@property(nonatomic, copy) NSDictionary *language, *country;

@end

@implementation CountryAndLanguageViewController

#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.language = params[@"language"];
        self.country = params[@"country"];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupControllers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingToParentViewController]) {
    
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod
- (void)setupControllers {
    @weakify(self)
    CountryViewController *countryVC = [[CountryViewController alloc] initWithParams:self.country ? @{@"country":self.country} : @{ @"country":@{
                                                                                               @"name":@"All Countries",
                                                                                               @"slug":@"",
                                                                                               }}];
    countryVC.segmentedControlItem = @"Country";
    countryVC.callback = ^(NSDictionary *country) {
        @strongify(self)
        self.country = country;
        self.callback(@{
                        @"language":self.language,
                        @"country":self.country
                        });

    };
    
    LanguageViewController *languageVC = [[LanguageViewController alloc] initWithParams:self.language ? @{@"language":self.language}: @{@"language":@{
                                                                                                  @"name":@"All Languages",
                                                                                                  @"slug":@"",
                                                                                                  }}];
    languageVC.segmentedControlItem = @"Language";
    languageVC.callback = ^(NSDictionary *language) {
        @strongify(self)
        self.language = language;
        self.callback(@{
                        @"language":self.language,
                        @"country":self.country
                        });

    };
    
    self.viewControllers = @[ countryVC, languageVC ];
    
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
