//
//  Explore_RootViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Explore_RootViewController.h"
#import "ExploreTableViewCell.h"
#import "Showcase.h"
#import "ExploreBannersView.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "ShowcaseReposViewController.h"
#import "TrendingReposViewController.h"
#import "PopularReposViewController.h"
#import "UserListViewController.h"

@interface Explore_RootViewController () <UITableViewDelegate, UITableViewDataSource, ExploreTableViewCellDelegate>
@property (nonatomic, strong) UITableView *exploreTabeView;

//@property (nonatomic, copy) NSArray<Showcase *> *showcases;
@property (nonatomic, copy) NSArray<OCTRepository *> *trendingRepos;
@property (nonatomic, copy) NSArray<OCTRepository *> *popularRepos;
@property (nonatomic, copy) NSArray<OCTUser *> *popularUsers;

//Banner
@property (nonatomic, strong) ExploreBannersView *myBannersView;

@end

@implementation Explore_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.exploreTabeView];
    self.trendingRepos = (NSArray *)[[YYCache sharedCache] objectForKey:ExploreTrendingReposCacheKey];
    [self fetchTrendingRepos];
    self.popularRepos = (NSArray *)[[YYCache sharedCache] objectForKey:ExplorePopularReposCacheKey];
    [self fetchPopularRepos];
    self.popularUsers = (NSArray *)[[YYCache sharedCache] objectForKey:ExplorePopularUsersCacheKey];
    [self fetchPopularUsers];
    self.myBannersView.curBannerList = (NSArray *)[[YYCache sharedCache] objectForKey:ExploreShowcasesCacheKey];
    [self fetchShowcases];

    //[self refreshBanner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 168;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExploreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ExploreTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.navigationController = self.navigationController;
    cell.delegate = self;
    cell.seeAllButton.tag = indexPath.section + 100;
    cell.section = indexPath.section;
    if (indexPath.section == 0) {
        cell.titleLabel.text = @"Trending repositories this week";
        [cell setModelArray:self.trendingRepos];
    } else if (indexPath.section == 1) {
        cell.titleLabel.text = @"Popular repositories";
        [cell setModelArray:self.popularRepos];
    } else if (indexPath.section == 2) {
        cell.titleLabel.text = @"Popular users";
        [cell setModelArray:self.popularUsers];
    }
    return cell;
}

#pragma mark - TabelViewCellDelegate

- (void)buttonClicked:(UIButton *)btn {
    NSInteger section = btn.tag - 100;
    if (section == 0) {
        DebugLog(@"点击了第一个");
        TrendingReposViewController *trendingReposVC = [[TrendingReposViewController alloc] init];
        [self.navigationController pushViewController:trendingReposVC animated:YES];
    } else if (section  == 1) {
        DebugLog(@"点击了第二个");
        PopularReposViewController *popularReposVC = [[PopularReposViewController alloc] init];
        [self.navigationController pushViewController:popularReposVC animated:YES];

    } else if (section == 2) {
        UserListViewController *userListVC = [[UserListViewController alloc] initWithUserListType:UserListModelTypePopularUsers];
        [self.navigationController pushViewController:userListVC animated:YES];
        DebugLog(@"点击了第三个");

    }
}

#pragma mark - API Request
- (void)fetchTrendingRepos {
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestTrendingRepositoriesSince:@"weekly" language:nil andBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                [[YYCache sharedCache] setObject:data forKey:ExploreTrendingReposCacheKey withBlock:nil];
                self.trendingRepos = data;
            }
            [self.exploreTabeView reloadData];
        });
    }];
}

- (void)fetchPopularRepos {
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestPopularRepositoriesWithLanguage:nil andBlock:^(id data, NSError *error) {
        @strongify(self)
       dispatch_async(dispatch_get_main_queue(), ^{
           if (data) {
               [[YYCache sharedCache] setObject:data forKey:ExplorePopularReposCacheKey withBlock:nil];
               self.popularRepos = data;
           }
           [self.exploreTabeView reloadData];
       });
    }];
}

- (void)fetchPopularUsers {
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestPopularUsersWithLocation:nil language:nil andBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                [[YYCache sharedCache] setObject:data forKey:ExplorePopularUsersCacheKey withBlock:nil];
                self.popularUsers = data;
            }
            [self.exploreTabeView reloadData];
        });

    }];
}

- (void)fetchShowcases {
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestShowcasesAndBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                self.myBannersView.curBannerList = data;
            }
            [self.exploreTabeView reloadData];
        });
    }];
}

#pragma mark - Getter & Setter

- (UITableView *)exploreTabeView {
    if (!_exploreTabeView) {
        _exploreTabeView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.showsVerticalScrollIndicator = NO;
            {
                UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
                tableView.contentInset = insets;
            }
            tableView.tableHeaderView = self.myBannersView;
            tableView;
        });
    }
    return _exploreTabeView;
}

- (ExploreBannersView *)myBannersView {
    @weakify(self)
    if (!_myBannersView) {
        _myBannersView = [ExploreBannersView new];
        _myBannersView.tapActionBlock = ^(Showcase *showcase){
            @strongify(self)
            ShowcaseReposViewController *showcaseReposVC = [[ShowcaseReposViewController alloc] initWithParams:@{ @"showcase":showcase }];
            [self.navigationController pushViewController:showcaseReposVC animated:YES];
        };
        //_exploreTabeView.tableHeaderView = _myBannersView;
    }
    return _myBannersView;
}

@end
