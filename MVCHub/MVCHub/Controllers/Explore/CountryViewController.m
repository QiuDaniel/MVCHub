//
//  CountryViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "CountryViewController.h"

@interface CountryViewController ()

@end

@implementation CountryViewController

#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.item = params[@"country"];
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Countries";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overwritten Method
- (NSString *)resourceName {
    return @"Countries";
}
@end
