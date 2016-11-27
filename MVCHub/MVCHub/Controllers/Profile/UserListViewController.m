//
//  UserListViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "UserListViewController.h"
#import "UserListTableViewCell.h"
#import "UserList.h"
#import "UserDetailViewController.h"
#import "CountryAndLanguageViewController.h"

@interface UserListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *userListTable;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSDictionary *country, *language;

@property (nonatomic, assign) UserListModelType type;
@property (nonatomic, strong) UserList *userList;

@end


@implementation UserListViewController

#pragma mark - Init

- (instancetype)initWithUserListType:(UserListModelType)userListType {
    self = [super init];
    if (self) {
        self.type = userListType;
        if (self.type == UserListModelTypeFollowing) {
            self.titleViewType = TitleViewTypeDefault;
            self.title = @"Following";
            self.message = @"No More Following";
        } else if (self.type == UserListModelTypeFollowers) {
            self.titleViewType = TitleViewTypeDefault;
            self.title = @"Followers";
            self.message = @"No More Followers";
        } else if (self.type == UserListModelTypePopularUsers) {
            self.titleViewType = TitleViewTypeDoubleTitle;
            NSDictionary *country = (NSDictionary *)[[YYCache sharedCache] objectForKey:PopularUsersCountryCacheKey];
            self.country = country ?: @{
                                        @"name":@"All Countries",
                                        @"slug": @"",
                                       };
            NSDictionary *language = (NSDictionary *)[[YYCache sharedCache] objectForKey:PopularUsersLanguageCacheKey];
            self.language = language ?: @{
                              @"name":@"All Languages",
                              @"slug": @"",
                              };
            self.message = @"No More Users";
        }
        self.userList = [[UserList alloc] init];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.userListTable];
    [self.userListTable.mj_header beginRefreshing];
    RAC(self, doubleTitleView.titleLabel.text) = [RACObserve(self, country) map:^(NSDictionary *country) {
        return country[@"name"];
    }];
    RAC(self, doubleTitleView.subtitleLabel.text) = [RACObserve(self, language) map:^(NSDictionary *language) {
        return language[@"name"];
    }];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.type == UserListModelTypePopularUsers) {
        [self setupRightNavBtn];
        [self.userListTable.mj_header beginRefreshing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserDetailViewController *userDetailVC = [[UserDetailViewController alloc] initWithUser:(OCTUser *)self.users[indexPath.row]];
    [self.navigationController pushViewController:userDetailVC animated:YES];
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserListCell"];
    if (!cell) {
        cell = [[UserListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UserListCell"];
    }
    OCTUser *tempUser = (OCTUser *)self.users[indexPath.row];
    [cell.avatarImageView sd_setImageWithURL:tempUser.avatarURL placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    cell.loginLabel.text = tempUser.login;
    cell.htmlLabel.text = tempUser.HTMLURL.absoluteString;
    
    return cell;
}
#pragma mark - Overwritten Method
- (void)setupRightNavBtn {
    [super setupNavBtn];
    [self addImageBarButtonWithImage:[UIImage
                                      octicon_imageWithIcon:@"Gear"
                                      backgroundColor:[UIColor clearColor]
                                      iconColor:[UIColor  whiteColor]
                                      iconScale:1
                                      andSize:CGSizeMake(22, 22)]
                              button:[UIButton new]
                              action:@selector(chooseLanguageAndCountry)
                             isRight:YES];
}

#pragma mark - Response Event
- (void)chooseLanguageAndCountry {
    CountryAndLanguageViewController *countryAndLanguageVC = [[CountryAndLanguageViewController alloc] initWithParams:@{ @"language":self.language, @"country":self.country }];
    @weakify(self)
    countryAndLanguageVC.callback = ^(NSDictionary *params) {
        @strongify(self)
        self.country = params[@"country"];
        self.language = params[@"language"];
        [[YYCache sharedCache] setObject:self.country forKey:PopularUsersCountryCacheKey withBlock:nil];
        [[YYCache sharedCache] setObject:self.language forKey:PopularUsersLanguageCacheKey withBlock:nil];
    };
    [self.navigationController pushViewController:countryAndLanguageVC animated:YES];
}


#pragma mark - API Request

- (void)loadNewData {
    NSUInteger page = 1;
    MVCWeakSelf
    [self.view beginLoading];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = kMBProgressHUD_Lable_Text;
    [[MVCHubAPIManager sharedManager] requestUserListWithUser:self.user userListType:self.type location:self.country[@"slug"] language:self.language[@"slug"] page:page perPage:UserListPerPage andBlock:^(NSArray *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf.view endLoading];
            [__weakSelf.userListTable.mj_header endRefreshing];
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            if (__weakSelf.type == UserListModelTypePopularUsers) {
                [__weakSelf.users removeAllObjects];
            }
            if (data) {
                for (int i = 0; i < data.count; i++) {
                    if (![__weakSelf.users containsObject:data[i]]) {
                        [__weakSelf.users addObject:data[i]];
                    }
                }
                [__weakSelf.userListTable reloadData];
            }

        });
    }];
}

- (void)loadMoreData {
    self.userList.page ++;
    MVCWeakSelf
    [[MVCHubAPIManager sharedManager] requestUserListWithUser:self.user userListType:self.type location:self.country[@"slug"] language:self.language[@"slug"] page:self.userList.page perPage:UserListPerPage andBlock:^(NSArray *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf.userListTable.mj_footer endRefreshing];
            if (data) {
                if ([__weakSelf.user.objectID isEqualToString:[OCTUser mvc_currentUserId]]) {
                    if (data.count > __weakSelf.users.count) {
                        __weakSelf.users = [NSMutableArray arrayWithArray:[data copy]];
                        [__weakSelf.userListTable reloadData];
                    } else {
                        [NSObject showAllTextDialog:__weakSelf.message xOffset:0.0 yOffset:200.0];
                    }
                } else {
                    if (data.count > 0) {
                        [__weakSelf.users addObjectsFromArray:[data copy]];
                        [__weakSelf.userListTable reloadData];
                    } else {
                        [NSObject showAllTextDialog:__weakSelf.message xOffset:0.0 yOffset:200.0];
                    }


                }
            }
        });
    }];
}

#pragma mark - Getters And Setters

- (UITableView *)userListTable {
    if (!_userListTable) {
        _userListTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
            tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
            tableView;
        });
    }
    return _userListTable;
}

- (NSMutableArray *)users {
    if (!_users) {
        _users = [[NSMutableArray alloc] init];
    }
    return _users;
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
