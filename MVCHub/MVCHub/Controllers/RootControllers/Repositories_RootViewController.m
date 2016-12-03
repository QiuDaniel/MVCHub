//
//  Repositories_RootViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Repositories_RootViewController.h"
#import "ReposTableViewCell.h"
#import "RepoDetailViewController.h"
#import "Repositories.h"

@interface Repositories_RootViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *reposTableView;
@property (nonatomic, copy) NSArray *repositories, *sectionIndexTitles;
@property (nonatomic, strong) NSMutableArray *reposArr;
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) Repositories *repos;

@end

static NSString *const ReposTableCell = @"ReposTableCell";

@implementation Repositories_RootViewController

#pragma mark - Init

+ (instancetype)newRepositoriesVCWithType:(Repositories_RootViewControllerType)type {
    Repositories_RootViewController *vc = [[Repositories_RootViewController alloc] init];
    vc.curIndex = type;
    return vc;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _curIndex = 0;
    }
    return self;
}
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.reposTableView];
    [self.reposTableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:ReposTableCell];
    self.repositories = [self fetchLocalData];
    self.sectionIndexTitles = [self sectionIndexTitlesWithRepositories:self.repositories];
    self.reposArr = [self dataSourceWithRepositories:self.repositories sectionIndex:self.sectionIndexTitles];
    [self fetchRemoteData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self fetchRepositories];
//    [self fetchStarredRepositories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OCTRepository *repository = ((Repositories *)self.reposArr[indexPath.section][indexPath.row]).repository;
    RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:@{ @"repository": repository }];
    [self.navigationController pushViewController:repoDetailVC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Repositories *repos = self.reposArr[indexPath.section][indexPath.row];
    return repos.height;
}

#pragma mark - TableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DebugLog(@"sectionIndexTitle.count=====>%ld",self.sectionIndexTitles.count);
    return self.sectionIndexTitles ? self.sectionIndexTitles.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [(NSArray *)self.reposArr[section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
   
    return self.sectionIndexTitles;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section >= self.sectionIndexTitles.count ? nil : self.sectionIndexTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReposTableCell forIndexPath:indexPath];
    Repositories *repos = self.reposArr[indexPath.section][indexPath.row];
    if (self.curIndex == Repositories_RootViewControllerTypeStarred) {
        repos.options = ReposViewModelOptionsShowOwnerLogin;
    }
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
    cell.updateTimeLabel.text = repos.updateTime;
    cell.languageLabel.text = repos.language;
    return cell;
}

#pragma mark - Private Methods
- (NSArray *)sectionIndexTitlesWithRepositories:(NSArray *)repositories {
    if (repositories.count == 0) return nil;
    NSArray *firstLetters = [repositories.rac_sequence map:^(OCTRepository *repository) {
        return repository.name.firstLetter;
    }].array;
    
    return [[NSSet setWithArray:firstLetters].rac_sequence.array sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}

- (NSMutableArray *)dataSourceWithRepositories:(NSArray *)repositories sectionIndex:(NSArray *)sectionIndex{
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    if (repositories.count == 0) return nil;
    for (int i = 0; i < sectionIndex.count; i++) {
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (OCTRepository *repository in repositories) {
            if ([repository.name.firstLetter isEqualToString:sectionIndex[i]]) {
                Repositories *repos = [[Repositories alloc] initWithRepository:repository];
                [tempArr addObject:repos];
            }
        }
        [mutableArr addObject:tempArr];
    }
    
    return mutableArr;
}

- (NSArray *)fetchLocalData {
    NSArray *repos = nil;
    if (self.curIndex == Repositories_RootViewControllerTypeOwned) {
        repos = [OCTRepository mvc_fetchUserRepositories];
    } else if (self.curIndex == Repositories_RootViewControllerTypeStarred) {
        repos = [OCTRepository mvc_fetchUserStarredRepositories];
    }
    return repos;
}

- (void)fetchRemoteData {
    if (self.curIndex == Repositories_RootViewControllerTypeOwned) {
        [self fetchRepositories];
    } else if (self.curIndex == Repositories_RootViewControllerTypeStarred) {
        [self fetchStarredRepositories];
    }
}
#pragma mark - API Request
- (void)fetchRepositories {
    MBProgressHUD *progressHUD = nil;
    if (self.repositories.count == 0) {
        progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.labelText = kMBProgressHUD_Lable_Text;
    }
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestForUserRepositoriesAndBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([self.reposTableView.mj_header isRefreshing]) {
                [self.reposTableView.mj_header endRefreshing];
            }
            if (data) {
                self.repositories = [data sortedArrayUsingComparator:^(OCTRepository *repo1, OCTRepository *repo2) {
                    return [repo1.name caseInsensitiveCompare:repo2.name];
                }];
                [OCTRepository mvc_matchStarredStatusForRepositories:self.repositories];
                self.sectionIndexTitles = [self sectionIndexTitlesWithRepositories:self.repositories];
                self.reposArr = [self dataSourceWithRepositories:self.repositories sectionIndex:self.sectionIndexTitles];
                [self.reposTableView reloadData];
            }

        });
    }];
}

- (void)fetchStarredRepositories {
    
    MBProgressHUD *progressHUD = nil;
    if (self.repositories.count == 0) {
        progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.labelText = kMBProgressHUD_Lable_Text;
    }
    @weakify(self)
    [[MVCHubAPIManager sharedManager] requestUserStarredRepositoriesAndBlock:^(id data, NSError *error) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([self.reposTableView.mj_header isRefreshing]) {
                [self.reposTableView.mj_header endRefreshing];
            }
            if (data) {
                self.repositories = [data sortedArrayUsingComparator:^(OCTRepository *repo1, OCTRepository *repo2) {
                    return [repo1.name caseInsensitiveCompare:repo2.name];
                }];
                [OCTRepository mvc_matchStarredStatusForRepositories:self.repositories];
                self.sectionIndexTitles = [self sectionIndexTitlesWithRepositories:self.repositories];
                self.reposArr = [self dataSourceWithRepositories:self.repositories sectionIndex:self.sectionIndexTitles];
                [self.reposTableView reloadData];
            }
        });
        
    }];
}

#pragma mark - Getter
- (UITableView *)reposTableView {
    if (!_reposTableView) {
        _reposTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.sectionIndexColor = [UIColor darkGrayColor];
            tableView.sectionIndexBackgroundColor = [UIColor clearColor];
            tableView.sectionIndexMinimumDisplayRowCount = 20;
            {
                UIEdgeInsets inserts = UIEdgeInsetsMake(0, 0, 49 + 64, 0);
                tableView.contentInset = inserts;
            }
            tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchRemoteData)];
            tableView;
        });
    }
    return _reposTableView;
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
