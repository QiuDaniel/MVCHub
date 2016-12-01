//
//  UserDetailViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/19.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "UserDetailViewController.h"
#import "ProfileAvatarHeaderView.h"
#import "UserDetail.h"
#import "SDWebImagePrefetcher.h"
#import "PublicActivityViewController.h"
#import "StarredReposViewController.h"


@interface UserDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) OCTUser *user;
@property (nonatomic, strong) UITableView *userDetailTable;
@property (nonatomic, strong) ProfileAvatarHeaderView *avatarHeaderView;
@property (nonatomic, strong) UserDetail *userDetail;
@end

@implementation UserDetailViewController
#pragma mark - Init
- (instancetype)initWithUser:(OCTUser *)user {
    self = [super init];
    if (self) {
        self.user = user;
        @weakify(self)
        [[MVCHubAPIManager sharedManager] requestUserInfoForUser:user andBlock:^(OCTUser *user, NSError *error) {
            @strongify(self)
            SDWebImagePrefetcher *imagePrefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
            imagePrefetcher.options = SDWebImageRefreshCached;
            [imagePrefetcher prefetchURLs:@[user.avatarURL ?: [NSNull null] ]];
            self.user = [OCTUser mvc_fetchUser:user];
            user.followingStatus = self.user.followingStatus;
            [self.user mergeValuesForKeysFromModel:user];
            self.userDetail.user = self.user;
            self.avatarHeaderView.user = self.user;
            [self.userDetailTable reloadData];
        }];
    }
    return self;
}

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        id user = params[@"user"];
        if ([user isKindOfClass:[OCTUser class]]) {
            self.user = (OCTUser *)user;
        } else if ([user isKindOfClass:[NSDictionary class]]) {
            self.user = [OCTUser modelWithDictionary:user error:nil];
        } else {
            self.user = [OCTUser mvc_currentUser];
        }
        @weakify(self)
        [[MVCHubAPIManager sharedManager] requestUserInfoForUser:self.user andBlock:^(OCTUser *user, NSError *error) {
            @strongify(self)
            SDWebImagePrefetcher *imagePrefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
            imagePrefetcher.options = SDWebImageRefreshCached;
            [imagePrefetcher prefetchURLs:@[user.avatarURL ?: [NSNull null] ]];
            self.user = [OCTUser mvc_fetchUser:user];
            user.followingStatus = self.user.followingStatus;
            [self.user mergeValuesForKeysFromModel:user];
            self.userDetail.user = self.user;
            self.avatarHeaderView.user = self.user;
            [self.userDetailTable reloadData];
        }];

    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.userDetailTable];
    self.title = self.user.login;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.avatarHeaderView parallaxHeaderInContentOffset:scrollView.contentOffset];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            NSDictionary *params = @{
                                     @"user":self.user
                                     };
            StarredReposViewController *starredReposVC = [[StarredReposViewController alloc] initWithParams:params];
            [self.navigationController pushViewController:starredReposVC animated:YES];
            
        } else if (indexPath.row == 2) {
            NSDictionary *params = @{
                                     @"user":self.user,
                                     @"type":@(1)
                                     };
            PublicActivityViewController *publicActivityVC = [[PublicActivityViewController alloc] initWithParams:params];
            [self.navigationController pushViewController:publicActivityVC animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", self.userDetail.email]]];
        } else if (indexPath.row == 3) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.userDetail.blog]];
        }

    }
}


#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3: 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UserDetailCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Person"
                                                          backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithHexString:@"0x24affc"]
                                                                iconScale:1
                                                                  andSize:kLeftImageSize];
                cell.textLabel.text = @"Name";
                cell.detailTextLabel.text = self.userDetail.name;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case 1:
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Star"
                                                          backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithHexString:@"0x4183c4"]
                                                                iconScale:1
                                                                  andSize:kLeftImageSize];
                cell.textLabel.text = @"Starred Repos";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 2:
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Rss"
                                                          backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithHexString:@"0x4078c0"]
                                                                iconScale:1
                                                                  andSize:kLeftImageSize];
                cell.textLabel.text = @"Public Activity";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Organization"
                                                          backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithHexString:@"0x24affc"]
                                                                iconScale:1
                                                                  andSize:kLeftImageSize];
                cell.textLabel.text = self.userDetail.company;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case 1:
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Location"
                                                          backgroundColor:[UIColor clearColor]
                                                                iconColor:[UIColor colorWithHexString:@"0x30C931"]
                                                                iconScale:1
                                                                  andSize:kLeftImageSize];
                cell.textLabel.text = self.userDetail.location;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case 2:
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Mail"
                                                          backgroundColor:[UIColor clearColor]
                                                                iconColor:[UIColor colorWithHexString:@"0x5586ED"]
                                                                iconScale:1
                                                                  andSize:kLeftImageSize];
                cell.textLabel.text = self.userDetail.email;
                if ([self.user.email isEqualToString:kEmptyPlaceHolder]) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                break;
            case 3:
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Link"
                                                          backgroundColor:[UIColor clearColor]
                                                                iconColor:[UIColor colorWithHexString:@"0x90DD2F"]
                                                                iconScale:1
                                                                  andSize:kLeftImageSize];
                cell.textLabel.text = self.userDetail.blog;
                    
                if ([self.user.blog isEqualToString:kEmptyPlaceHolder]) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }

                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - Getter & Setter

- (UITableView *)userDetailTable {
    if (!_userDetailTable) {
        _userDetailTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStyleGrouped];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.tableHeaderView = self.avatarHeaderView;
            tableView;
        });
    }
    return _userDetailTable;
}

- (UIView *)avatarHeaderView {
    if (!_avatarHeaderView) {
        _avatarHeaderView = [[ProfileAvatarHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height / 2) user:self.user];
        _avatarHeaderView.navgationController = self.navigationController;
    }
    return _avatarHeaderView;
}

- (UserDetail *)userDetail {
    if (!_userDetail) {
        _userDetail = [[UserDetail alloc] initWithUser:self.user];
    }
    return _userDetail;
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
