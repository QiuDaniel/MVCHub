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

@end

static NSString *const StarredReposTableCell = @"StarredReposTableCell";

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


#pragma mark - Getter

- (UITableView *)starredTableView {
    if (!_starredTableView) {
        _starredTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
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
