//
//  AboutViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "AboutViewController.h"
#import "UserDetailViewController.h"
#import "FeedbackViewController.h"
#import "AboutHeaderView.h"
#import "RepoDetailViewController.h"

@interface AboutViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *aboutTableView;

@end

@implementation AboutViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"About";
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xefeff4"];
    [self.view addSubview:self.aboutTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.hidden = YES;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Source Code";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Author";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Feedback";
    }
    
    return cell;
}
#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 0 : 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        NSDictionary *params = @{
                                 @"repository":@{
                                            @"ownerLogin":kMVCHub_Owner_Login,
                                            @"name":kMVCHub_Name
                                         },
                                 @"referenceName":@"refs/heads/master"
                                 };
        RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:params];
        [self.navigationController pushViewController:repoDetailVC animated:YES];
    } else if (indexPath.row == 2) {
        NSDictionary *params = @{
                                 @"user":@{
                                            @"login":kMVCHub_Owner_Login
                                         }
                                 };
        UserDetailViewController *userDetailVC = [[UserDetailViewController alloc] initWithParams:params];
        [self.navigationController pushViewController:userDetailVC animated:YES];
    } else if (indexPath.row == 3) {
        FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }
}

#pragma mark - Getter

- (UITableView *)aboutTableView {
    if (!_aboutTableView) {
        _aboutTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStyleGrouped];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.tableHeaderView = [[AboutHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 112)];
            {
                UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreen_Height - 10 - 14 - 64 - 14, kScreen_Width, 14)];
                usernameLabel.text = @"QiuDaniel";
                usernameLabel.font = [UIFont systemFontOfSize:12];
                usernameLabel.textColor = UIColor.lightGrayColor;
                usernameLabel.textAlignment = NSTextAlignmentCenter;
                [tableView addSubview:usernameLabel];
            }
            {
                UILabel *copyRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreen_Height - 10 - 14 - 64, kScreen_Width, 14)];
                copyRightLabel.text = @"Copyright (c) 2016 QiuDaniel. All rights reserved.";
                copyRightLabel.font = [UIFont systemFontOfSize:12];
                copyRightLabel.textColor = UIColor.lightGrayColor;
                copyRightLabel.textAlignment = NSTextAlignmentCenter;
                [tableView addSubview:copyRightLabel];
            }
            tableView;
        });
    }
    return _aboutTableView;
}
@end
