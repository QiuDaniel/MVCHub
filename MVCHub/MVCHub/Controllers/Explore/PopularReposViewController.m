//
//  PopularReposViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "PopularReposViewController.h"
#import "ReposTableViewCell.h"
#import "RepoDetailViewController.h"
#import "Repositories.h"
#import "LanguageViewController.h"

@interface PopularReposViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *popularReposTableView;
@property (nonatomic, copy) NSArray *repositories;
@property (nonatomic, strong) NSMutableArray *reposArr;
@property (nonatomic, copy) NSDictionary *language;


@end

static NSString *const PopularReposViewCell = @"PopularReposViewCell";

@implementation PopularReposViewController

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        NSDictionary *language = (NSDictionary *)[[YYCache sharedCache] objectForKey:PopularReposLanguageCacheKey];
        self.language = language ?: @{
                                      @"name":@"All languages",
                                      @"slug":@"",
                                      };
        RAC(self, title) = [RACObserve(self, language) map:^(NSDictionary *language) {
            return language[@"name"];
        }];
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.popularReposTableView];
    //[self setupNavBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchPopularRepos];
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
    ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PopularReposViewCell forIndexPath:indexPath];
    Repositories *repos = self.reposArr[indexPath.row];
    repos.options = ReposViewModelOptionsShowOwnerLogin;
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
    Repositories *repos = self.reposArr[indexPath.row];
    RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:@{ @"repository":repos.repository }];
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

#pragma mark - Overwritten Method
- (void)setupNavBtn {
    [super setupNavBtn];
    [self addImageBarButtonWithImage:[UIImage
                                      octicon_imageWithIcon:@"Gear"
                                      backgroundColor:[UIColor clearColor]
                                      iconColor:[UIColor  whiteColor]
                                      iconScale:1
                                      andSize:CGSizeMake(22, 22)]
                              button:[UIButton new]
                              action:@selector(chooseLanguage)
                             isRight:YES];
}

#pragma mark - Response Event
- (void)chooseLanguage {
    LanguageViewController *languageVC = [[LanguageViewController alloc] initWithParams:@{ @"language":self.language ?: @{} }];
    @weakify(self)
    languageVC.callback = ^(NSDictionary *language) {
        @strongify(self)
        self.language = language;
        [[YYCache sharedCache] setObject:language forKey:PopularReposLanguageCacheKey withBlock:nil];
    };
    [self.navigationController pushViewController:languageVC animated:YES];
}


#pragma mark - API Request
- (void)fetchPopularRepos {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = kMBProgressHUD_Lable_Text;
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestPopularRepositoriesWithLanguage:self.language[@"slug"] andBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (data) {
                self.repositories = data;
                self.reposArr = [self dataSourceWithRepositories:self.repositories];
            }
            [self.popularReposTableView reloadData];
        });
        
    }];
}

#pragma mark - Getter
- (UITableView *)popularReposTableView {
    if (!_popularReposTableView) {
        _popularReposTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:PopularReposViewCell];
            tableView;
        });
    }
    return _popularReposTableView;
}
@end
