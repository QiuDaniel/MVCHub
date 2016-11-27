//
//  TrendingViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "TrendingViewController.h"
#import "ReposTableViewCell.h"
#import "RepoDetailViewController.h"
#import "Repositories.h"


@interface TrendingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *trendingTableView;
@property (nonatomic, copy) NSArray *repositories;
@property (nonatomic, copy) NSDictionary *since, *language;
@property (nonatomic, strong) NSMutableArray *reposArr;

@end

static NSString *const TrendingTableViewCell = @"TrendingTableViewCell";

@implementation TrendingViewController

#pragma mark - Init

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.since = params[@"since"];
        self.language = params[@"language"];
        //self.repositories = params[@"repositories"];
        //self.reposArr = [self dataSourceWithRepositories:self.repositories];
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.trendingTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchTrendingRepositories];
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
    ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TrendingTableViewCell forIndexPath:indexPath];
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
    Repositories *repos = self.reposArr[indexPath.row];
    RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:@{ @"repository":repos.repository }];
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

#pragma mark - API Request
- (void)fetchTrendingRepositories {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = kMBProgressHUD_Lable_Text;
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestTrendingRepositoriesSince:self.since[@"slug"] language:self.language[@"slug"] andBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (data) {
                self.repositories = data;
                self.reposArr = [self dataSourceWithRepositories:self.repositories];
            }
            [self.trendingTableView reloadData];
        });
        
    }];
}

#pragma mark - Getter & Setter
- (UITableView *)trendingTableView {
    if (!_trendingTableView) {
        _trendingTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:TrendingTableViewCell];
            {
                UIEdgeInsets insets = UIEdgeInsetsMake(64 + 45, 0, 0, 0);
                tableView.contentInset = insets;
            }
            tableView;
        });
    }
    return _trendingTableView;
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
