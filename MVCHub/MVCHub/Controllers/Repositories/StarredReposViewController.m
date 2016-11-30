//
//  StarredReposViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/30.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "StarredReposViewController.h"
#import "Repositories.h"
#import "ReposTableViewCell.h"
#import "RepoDetailViewController.h"

@interface StarredReposViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *starredTableView;
@property (nonatomic, strong) NSMutableArray *reposArr, *repositories;

@property (nonatomic, strong) Repositories *repos;
@property (nonatomic, strong) OCTUser *user;

@property (nonatomic, assign) NSUInteger page;

@end

static NSString *const StarredReposTableCell = @"StarredReposTableCell";
static const NSUInteger PerPage = 20;

@implementation StarredReposViewController

#pragma mark - Init

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.user = params[@"user"];
    }
    return self;
}


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Starred Repos";
    [self.view addSubview:self.starredTableView];
    self.reposArr = [self dataSourceWithRepositories:[self fetchLocalData]];
    [self.starredTableView.mj_header beginRefreshing];
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
    return self.reposArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StarredReposTableCell forIndexPath:indexPath];
    Repositories *repos = self.reposArr[indexPath.row];
    CGSize iconSize = cell.iconImageView.frame.size;
    if (repos.repository.isPrivate) {
        cell.iconImageView.image = [UIImage octicon_imageWithIcon:@"Lock"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor darkGrayColor]
                                                        iconScale:1
                                                          andSize:iconSize];
    } else if (repos.repository.isFork) {
        cell.iconImageView.image = [UIImage octicon_imageWithIcon:@"RepoForked"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor darkGrayColor]
                                                        iconScale:1
                                                          andSize:iconSize];
    } else {
        cell.iconImageView.image = [UIImage octicon_imageWithIcon:@"Repo"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor darkGrayColor]
                                                        iconScale:1
                                                          andSize:iconSize];
    }
    cell.nameLabel.attributedText = repos.name;
    cell.desLabel.attributedText = repos.repoDescription;
    cell.starCountLabel.text = [@(repos.repository.stargazersCount) stringValue];
    cell.forkCountLabel.text = [@(repos.repository.forksCount) stringValue];
    //cell.updateTimeLabel.text = repos.updateTime;
    cell.languageLabel.text = repos.language;
    
    return cell;
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Repositories *repos = self.reposArr[indexPath.row];
    return repos.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OCTRepository *repository = self.repositories[indexPath.row];
    RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:@{ @"repository":repository }];
    [self.navigationController pushViewController:repoDetailVC animated:YES];
}


#pragma mark - Private Methods

- (NSMutableArray *)dataSourceWithRepositories:(NSArray *)repositories {
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    if (repositories.count == 0) {
        return nil;
    }
    for (OCTRepository *repository in repositories) {
        Repositories *repos = [[Repositories alloc] initWithRepository:repository];
        [mutableArr addObject:repos];
    }
    return mutableArr;
}

- (NSArray *)fetchLocalData {
    NSArray *repos = nil;
    if ([self.user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
        repos = [OCTRepository mvc_fetchUserStarredRepositoriesWithPage:1 perPage:PerPage];
    }
    return repos;
}

#pragma mark - API Request
- (void)loadNewData {
    self.page = 1;
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestStarredRepositoriesForUser:self.user page:self.page perPage:PerPage andBlock:^(NSArray *data, NSError *error) {
       @strongify(self)
        [self.starredTableView.mj_header endRefreshing];
        if (data) {
            for (int i = 0; i < data.count; i++) {
                if ([self.repositories containsObject:data[i]]) {
                    [self.repositories addObject:data[i]];
                }
            }
            self.reposArr = [self dataSourceWithRepositories:self.repositories];
            [self.starredTableView reloadData];
        }
    }];
}

- (void)loadMoreData {
    self.page++;
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestStarredRepositoriesForUser:self.user page:self.page perPage:PerPage andBlock:^(NSArray *data, NSError *error) {
        @strongify(self)
        [self.starredTableView.mj_footer endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data.count > 0) {
                [self.repositories addObject:[data copy]];
                self.reposArr = [self dataSourceWithRepositories:self.repositories];
            } else {
                [NSObject showAllTextDialog:@"No more Repositories" xOffset:0.0 yOffset:200.0];
            }
            [self.starredTableView reloadData];
        });
    }];
}

#pragma mark - Getter

- (UITableView *)starredTableView {
    if (!_starredTableView) {
        _starredTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:StarredReposTableCell];
            tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
            tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
            tableView;
        });
    }
    return _starredTableView;
}

- (NSMutableArray *)repositories {
    if (!_repositories) {
        _repositories = [[NSMutableArray alloc] init];
    }
    return _repositories;
}

@end
