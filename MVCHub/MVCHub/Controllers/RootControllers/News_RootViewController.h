//
//  News_RootViewController.h
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, RefreshingType) {
    RefreshingTypeHeader,
    RefreshingTypeFooter
};

@interface News_RootViewController : BaseViewController

@property (nonatomic, strong) UITableView *newsTableView;
@property (nonatomic, strong) OCTUser *user;
@property (nonatomic, strong) News *news;

@end
