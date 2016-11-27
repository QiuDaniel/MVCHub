//
//  PublicReposViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/18.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "PublicReposViewController.h"
#import "ReposTableViewCell.h"
#import "Repositories.h"
#import "RepoDetailViewController.h"

@interface PublicReposViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *publicReposTableView;
@property (nonatomic, strong) NSMutableArray *reposArr, *repositories;
@property (nonatomic, strong) OCTUser *user;
@property (nonatomic, assign) NSUInteger page;

@end

static NSString *const PublicReposTableViewCell = @"PublicReposTableViewCell";
static const NSUInteger PerPage = 20;

@implementation PublicReposViewController

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
    [self.view addSubview:self.publicReposTableView];
    self.reposArr = [self dataSourceWithRepositories:[self fetchLocalData]];
    [self loadNewData];
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
    ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PublicReposTableViewCell forIndexPath:indexPath];
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

- (NSArray *)fetchLocalData {
    if ([self isCurrentUser]) {
        return [OCTRepository mvc_fetchUserPublicRepositoriesWithPage:1 perPage:PerPage];
    }
    return nil;
}

- (BOOL)isCurrentUser {
    return [self.user.objectID isEqualToString:[OCTUser mvc_currentUserId]];
}

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

#pragma mark - API Request

- (void)loadNewData {
    self.page = 1;
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestPublicRepositoriesForUser:self.user page:self.page perPage:PerPage andBlock:^(NSArray *data, NSError *error) {
        @strongify(self)
        [self.publicReposTableView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                for (int i = 0; i < data.count; i++) {
                    if (![self.repositories containsObject:data[i]]) {
                        [self.repositories addObject:data[i]];
                    }
                }
                self.reposArr = [self dataSourceWithRepositories:self.repositories];
            }
            [self.publicReposTableView reloadData];
        });
    }];
}

- (void)loadMoreData {
    self.page++;
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestPublicRepositoriesForUser:self.user page:self.page perPage:PerPage andBlock:^(NSArray *data, NSError *error) {
        @strongify(self)
        [self.publicReposTableView.mj_footer endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data.count > 0) {
                [self.repositories addObjectsFromArray:[data copy]];
                self.reposArr = [self dataSourceWithRepositories:self.repositories];
            } else {
                [NSObject showAllTextDialog:@"No more Repositories" xOffset:0.0 yOffset:200.0];
            }
            [self.publicReposTableView reloadData];
        });
        
    }];
}

#pragma mark - Getter

- (UITableView *)publicReposTableView {
    if (!_publicReposTableView) {
        _publicReposTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:PublicReposTableViewCell];
            tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
            tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
            tableView;
        });
    }
    return _publicReposTableView;
}

- (NSMutableArray *)repositories {
    if (!_repositories) {
        _repositories = [[NSMutableArray alloc] init];
    }
    return _repositories;
}
@end
