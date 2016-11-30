//
//  PublicActivityViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/29.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "PublicActivityViewController.h"

@interface PublicActivityViewController ()
@end

@implementation PublicActivityViewController
#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.news.title = @"Public Activity";
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.newsTableView.frame = kScreen_Bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter

@end
