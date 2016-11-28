//
//  RepoSettingsViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/5.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RepoSettingsViewController.h"
#import "RepoSettingsOwnerTableViewCell.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"
#import "UserDetailViewController.h"

@interface RepoSettingsViewController () <UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UMSocialUIDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) OCTRepository *repository;

@end

static NSString *const RepoSettingsOwnerCell = @"RepoSettingsOwnerCell";

@implementation RepoSettingsViewController

#pragma mark - Init

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.repository = params[@"repository"];
        DebugLog(@"repository====>%@",self.repository);
        if (self.repository.starredStatus == OCTRepositoryStarredStatusUnknown) {
            BOOL hasStarred = [OCTRepository mvc_hasUserStarredRepository:self.repository];
            self.repository.starredStatus = hasStarred ? OCTRepositoryStarredStatusYES : OCTRepositoryStarredStatusNO;
        }
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[RepoSettingsOwnerTableViewCell class] forCellReuseIdentifier:RepoSettingsOwnerCell];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Settings";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSDictionary *dictionary = @{
                                     @"login":self.repository.ownerLogin ?: @"",
                                     @"avatarURL":self.repository.ownerAvatarURL.absoluteString ?: @""
                                     };
        UserDetailViewController *userDetailVC = [[UserDetailViewController alloc] initWithParams:@{@"user":dictionary}];
        [self.navigationController pushViewController:userDetailVC animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [[MVCHubAPIManager sharedManager] requestToStarRepository:self.repository andBlock:^(id data, NSError *error) {
                DebugLog(@"RepositoryStarredStatus=========>%@",data);
            }];
        } else if (indexPath.row == 1) {
            [[MVCHubAPIManager sharedManager] requestToUnstarRepository:self.repository andBlock:^(id data, NSError *error) {
                DebugLog(@"RepositoryStarredStatus=====>%@",data);
            }];
        }
    } else if (indexPath.section == 2) {

        UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:self.repository.ownerAvatarURL.absoluteString];
        NSString *title = self.repository.name;
        NSString *shareText = self.repository.repoDescription;
        NSString *url = self.repository.HTMLURL.absoluteString;
        
        // Wechat Session
        [UMSocialData defaultData].extConfig.wechatSessionData.urlResource = urlResource;
        [UMSocialData defaultData].extConfig.wechatSessionData.title = title;
        [UMSocialData defaultData].extConfig.wechatSessionData.shareText = shareText;
        [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
        [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
        
        // Wechat Timeline
        [UMSocialData defaultData].extConfig.wechatTimelineData.urlResource = urlResource;
        [UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
        [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = shareText;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
        
        // Wechat Favorite
        [UMSocialData defaultData].extConfig.wechatFavoriteData.urlResource = urlResource;
        [UMSocialData defaultData].extConfig.wechatFavoriteData.title = title;
        [UMSocialData defaultData].extConfig.wechatFavoriteData.shareText = shareText;
        [UMSocialData defaultData].extConfig.wechatFavoriteData.url = url;
        
        NSArray *snsNames = @[ UMShareToWechatSession, UMShareToWechatTimeline, UMShareToWechatFavorite];
        [UMSocialSnsService presentSnsIconSheetView:self appKey:kUMengAPPKey shareText:@"来自CatHub的分享" shareImage:nil shareToSnsNames:snsNames delegate:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 90 : 44;
}

#pragma mark - TableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 || section == 2) ? 1 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    if (indexPath.section == 0) {
        RepoSettingsOwnerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RepoSettingsOwnerCell forIndexPath:indexPath];
        cell.avatarImageView.image = [UIImage imageNamed:@"default-avatar"];
        [cell.avatarImageView setImageWithURL:self.repository.ownerAvatarURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.topLabel.text = self.repository.ownerLogin;
        cell.bottomLabel.text = self.repository.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Star"
                                                      backgroundColor:[UIColor clearColor]
                                                            iconColor:[UIColor colorWithHexString:@"0x4183C4"]
                                                            iconScale:1
                                                              andSize:kLeftImageSize];
                cell.textLabel.text = @"Star";
                [[RACObserve(self.repository, starredStatus)
                  deliverOnMainThread]
                 subscribeNext:^(NSNumber *starredStatus) {
                     if (starredStatus.unsignedIntegerValue == OCTRepositoryStarredStatusYES) {
                         cell.accessoryType = UITableViewCellAccessoryCheckmark;
                     } else {
                         cell.accessoryType = UITableViewCellAccessoryNone;
                     }
                 }];
            }
                break;
            case 1:
            {
                cell.imageView.image = [UIImage octicon_imageWithIcon:@"Star"
                                                      backgroundColor:[UIColor clearColor]
                                                            iconColor:[UIColor lightGrayColor]
                                                            iconScale:1
                                                              andSize:kLeftImageSize];
                cell.textLabel.text = @"Unstar";
                [[RACObserve(self.repository, starredStatus)
                  deliverOnMainThread]
                 subscribeNext:^(NSNumber *starredStatus) {
                     if (starredStatus.unsignedIntegerValue == OCTRepositoryStarredStatusNO) {
                         cell.accessoryType = UITableViewCellAccessoryCheckmark;
                     } else {
                         cell.accessoryType = UITableViewCellAccessoryNone;
                     }
                 }];
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"Share To Friends";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Watchers Count";
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%lu", self.repository.watchersCount];
            label.textColor = [UIColor colorWithHexString:@"0x8e8e93"];
            [label sizeToFit];
            cell.accessoryView = label;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Open Issues Count";
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%lu", self.repository.openIssuesCount] ;
            label.textColor = [UIColor colorWithHexString:@"0x8e8e93"];
            [label sizeToFit];
            cell.accessoryView = label;
        }
    }
    return cell;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStyleGrouped];
        _tableView.tintColor = [UIColor colorWithHexString:@"0x4183C4"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
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
