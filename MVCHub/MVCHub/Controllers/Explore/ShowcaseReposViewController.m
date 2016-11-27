//
//  ShowcaseReposViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/18.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ShowcaseReposViewController.h"
#import "ReposTableViewCell.h"
#import "Showcase.h"
#import "RepoDetailViewController.h"
#import "Repositories.h"
#import "ShowcaseReposHeaderView.h"

@interface ShowcaseReposViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *showcaseTableView;
@property (nonatomic, strong) Showcase *showcase;
@property (nonatomic, copy) NSArray *repositories;
@property (nonatomic, strong) NSMutableArray *reposArr;

@property (nonatomic, strong) ShowcaseReposHeaderView *headerView;

@end

@implementation ShowcaseReposViewController

#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.showcase = params[@"showcase"];
    }
    return self;
    
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Showcase";
    [self.view addSubview:self.showcaseTableView];
    [self fetchShowcaseRepos];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repositories.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ReposTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OCTRepository *repository = self.repositories[indexPath.row];
    RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:@{ @"repository":repository }];
    [self.navigationController pushViewController:repoDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Repositories *repos = self.reposArr[indexPath.row];
    return repos.height;
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

#pragma mark - API Request;
- (void)fetchShowcaseRepos {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = kMBProgressHUD_Lable_Text;
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestShowcaseRepositoriesWithSlug:self.showcase.slug andBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (data) {
                self.repositories = data;
                self.reposArr = [self dataSourceWithRepositories:self.repositories];
            }
            [self.showcaseTableView reloadData];
        });
        
    }];
}

#pragma mark - Getter & Setter
- (UITableView *)showcaseTableView {
    if (!_showcaseTableView) {
        _showcaseTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.tableHeaderView = self.headerView;
            tableView;
        });
    }
    return _showcaseTableView;
}

- (ShowcaseReposHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [ShowcaseReposHeaderView new];
        _headerView.showcase = self.showcase;
    }
    return _headerView;
}
@end
