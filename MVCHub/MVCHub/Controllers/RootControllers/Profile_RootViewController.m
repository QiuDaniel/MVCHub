//
//  Profile_RootViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Profile_RootViewController.h"
#import "ProfileAvatarHeaderView.h"
#import "Profile.h"
#import "SettingsViewController.h"
#import "Login.h"
#import "SDWebImagePrefetcher.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

@interface Profile_RootViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *userTableView;
@property (nonatomic, strong) ProfileAvatarHeaderView *headerView;
@property (nonatomic, strong) Profile *profile;
@end

@implementation Profile_RootViewController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([Login curLoginUser].avatarURL) { //预加载头像
            SDWebImagePrefetcher *imagePrefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
            imagePrefetcher.options = SDWebImageRefreshCached;
            [imagePrefetcher prefetchURLs:@[[Login curLoginUser].avatarURL ?: [NSNull null] ]];
        }
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"Profile";
    self.profile = [[Profile alloc] init];
    self.userTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        {
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            tableView.contentInset = insets;
        }
        tableView;
    });
    [self.view addSubview:self.userTableView];
    [self.userTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.headerView = [[ProfileAvatarHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height / 2) user:[Login curLoginUser]];
    self.headerView.navgationController = self.navigationController;
    self.userTableView.tableHeaderView = self.headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle )preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.headerView parallaxHeaderInContentOffset:scrollView.contentOffset];
}


#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 4:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ProfileCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage octicon_imageWithIcon:@"Organization"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor colorWithHexString:@"0x24affc"]
                                                        iconScale:1
                                                          andSize:kLeftImageSize];
            cell.textLabel.text = self.profile.company;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.imageView.image = [UIImage octicon_imageWithIcon:@"Location"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor colorWithHexString:@"0x30C931"]
                                                        iconScale:1
                                                          andSize:kLeftImageSize];
            cell.textLabel.text = self.profile.location;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 2) {
            cell.imageView.image = [UIImage octicon_imageWithIcon:@"Mail"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor colorWithHexString:@"0x5586ed"]
                                                        iconScale:1
                                                          andSize:kLeftImageSize];
            cell.textLabel.text = self.profile.email;
            if ([self.profile.email isEqualToString:kEmptyPlaceHolder]) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        } else if (indexPath.row == 3) {
            cell.imageView.image = [UIImage octicon_imageWithIcon:@"Link"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor colorWithHexString:@"0x90DD2F"]
                                                        iconScale:1
                                                          andSize:kLeftImageSize];
            cell.textLabel.text = self.profile.blog;
            
            if ([self.profile.blog isEqualToString:kEmptyPlaceHolder]) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

        }
    } else if (indexPath.section == 1) {
        cell.imageView.image = [UIImage octicon_imageWithIcon:@"Gear"
                                              backgroundColor:[UIColor clearColor]
                                                    iconColor:[UIColor colorWithHexString:@"0x24AFFC"]
                                                    iconScale:1
                                                      andSize:kLeftImageSize];
        cell.textLabel.text = @"Settings";
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15 : 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == tableView.numberOfSections - 1) ? 15 : 7;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", self.profile.email]]];
        } else if (indexPath.row == 3) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.profile.blog]];
        }
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
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
