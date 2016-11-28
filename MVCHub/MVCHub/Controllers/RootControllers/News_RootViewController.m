//
//  News_RootViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "News_RootViewController.h"
#import "NewsTableViewCell.h"
#import "NetWorkHeaderView.h"
#import "Login.h"
#import "News.h"
#import "New.h"
#import "UserDetailViewController.h"
#import "RepoDetailViewController.h"
#import "WebViewController.h"

@interface News_RootViewController () <UITableViewDelegate, UITableViewDataSource, NewsAvatarButtonDelegate>

@property (nonatomic, strong) UITableView *newsTableView;
@property (nonatomic, strong) NSMutableArray *newsArr;

@property (nonatomic, strong) News *news;

@end

@implementation News_RootViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.news.title;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.newsTableView];
    [self.newsTableView.mj_header beginRefreshing];
    [self judgeNetworkStatus];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NewsAvatarButtonDelegate
- (void)tapAvatarButton:(UIButton *)btn {
    OCTEvent *tempEvent = (OCTEvent *)self.newsArr[btn.tag - 100];
    NSURL *URL = [NSURL mvc_userLinkWithLogin:tempEvent.actorLogin];

    UserDetailViewController *userDetialVC = [[UserDetailViewController alloc] initWithParams:URL.mvc_dictionary];
    [self.navigationController pushViewController:userDetialVC animated:YES];
    
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OCTEvent *tempEvent = (OCTEvent *)self.newsArr[indexPath.row];
    New *new = [[New alloc] initWithEvent:tempEvent];
    return new.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OCTEvent *tempEvent = (OCTEvent *)self.newsArr[indexPath.row];
    NSURL *URL = tempEvent.mvc_Link;
    NSString *title = [[[[URL.absoluteString componentsSeparatedByString:@"?"].lastObject componentsSeparatedByString:@"="].lastObject stringByReplacingOccurrencesOfString:@"-" withString:@" "] stringByReplacingOccurrencesOfString:@"@" withString:@"#"];
    if (URL.type == MVCLinkTypeRepository) {
        RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:URL.mvc_dictionary];
        [self.navigationController pushViewController:repoDetailVC animated:YES];
    } else if (URL.type == MVCLinkTypeUnknown) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        WebViewController *webViewVC = [[WebViewController alloc] initWithParams:@{
                                                                                  @"title":title ?: @"",
                                                                                  @"request":request ?: @"",
                                                                                  }];
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
    DebugLog(@"didClickLinkCommand: %@, title: %@", URL, title);
    DebugLog(@"点击了第%ld行",(unsigned long)indexPath.row);
}
#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsTableCell"];
    if (!cell) {
        cell = [[NewsTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NewsTableCell"];
    }
    OCTEvent *tempEvent = (OCTEvent *)self.newsArr[indexPath.row];
    New *new = [[New alloc] initWithEvent:tempEvent];
    cell.avatarButton.tag = indexPath.row + 100;
    [cell.avatarButton sd_setImageWithURL:tempEvent.actorAvatarURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    cell.detailLabel.height = new.textLayout.textBoundingSize.height;
    cell.detailLabel.textLayout = new.textLayout;
    cell.delegate = self;

    MVCWeakSelf
    cell.detailLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        text = [text attributedSubstringFromRange:range];
        NSDictionary *attributes = [text attributesAtIndex:0 effectiveRange:nil];
        NSURL *URL = attributes[LinkAttributeName];
        NSString *title = [[[[URL.absoluteString componentsSeparatedByString:@"?"].lastObject componentsSeparatedByString:@"="].lastObject stringByReplacingOccurrencesOfString:@"-" withString:@" "] stringByReplacingOccurrencesOfString:@"@" withString:@"#"];
        if (URL.type == MVCLinkTypeUser) {
            UserDetailViewController *userDetialVC = [[UserDetailViewController alloc] initWithParams:URL.mvc_dictionary];
            [__weakSelf.navigationController pushViewController:userDetialVC animated:YES];
        } else if (URL.type == MVCLinkTypeUnknown) {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            WebViewController *webViewVC = [[WebViewController alloc] initWithParams:@{
                                                                                       @"title":title ?: @"",
                                                                                       @"request":request ?: @"",
                                                                                       }];
            [__weakSelf.navigationController pushViewController:webViewVC animated:YES];
        } else if (URL.type == MVCLinkTypeRepository) {
            RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:URL.mvc_dictionary];
            [__weakSelf.navigationController pushViewController:repoDetailVC animated:YES];

        }
    };
    return cell;
}

#pragma mark - Private Methods
- (void)judgeNetworkStatus {
    if (self.news.type == NewsViewTypeNews) {
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
        NetWorkHeaderView *networkHeaderView = [[NetWorkHeaderView alloc] initWithFrame:tableHeaderView.bounds];
        [tableHeaderView addSubview:networkHeaderView];
        
        RAC(self.newsTableView, tableHeaderView) = [RACObserve(MVCSharedAppDelegate, networkStatus) map:^(NSNumber *networkStatus) {
            return networkStatus.integerValue == NotReachable ? tableHeaderView : nil;
        }];
    }
}

- (void)isLoading:(RefreshingType)type {
    switch (type) {
        case RefreshingTypeHeader:
            if (self.newsTableView.mj_header.isRefreshing) {
                self.titleViewType = TitleViewTypeLoadingTitle;
            } else {
                self.titleViewType = TitleViewTypeDefault;
            }
            break;
            
        case RefreshingTypeFooter:
            if (self.newsTableView.mj_footer.isRefreshing) {
                self.titleViewType = TitleViewTypeLoadingTitle;
            } else {
                self.titleViewType = TitleViewTypeDefault;
            }

            break;
    }
    
}

#pragma mark - Request API

- (void)loadNewData {
    [self isLoading:RefreshingTypeHeader];
    NSUInteger page = 1;
    MVCWeakSelf
    [[MVCHubAPIManager sharedManager] requestNewsForUser:[Login curLoginUser] newsType:NewsViewTypeNews page:page perPage:NewsPerPage andBlock:^(NSArray *data, NSError *error) {
        [__weakSelf.newsTableView.mj_header endRefreshing];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self isLoading:RefreshingTypeHeader];
        });
        if (data) {
            for (int i = 0; i < data.count; i++) {
                if (![__weakSelf.newsArr containsObject:data[i]]) {
                    [__weakSelf.newsArr addObject:data[i]];
                }
            }
            [__weakSelf.newsTableView reloadData];
        }

        
    }];
}

- (void)loadMoreData {
    [self isLoading:RefreshingTypeFooter];
    self.news.page++;
    MVCWeakSelf
    [[MVCHubAPIManager sharedManager] requestNewsForUser:[Login curLoginUser] newsType:NewsViewTypeNews page:self.news.page perPage:NewsPerPage andBlock:^(NSArray *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf.newsTableView.mj_footer endRefreshing];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self isLoading:RefreshingTypeFooter];
            });
            if (data) {
                if (data.count > 0) {
                    [__weakSelf.newsArr addObjectsFromArray:[data copy]];
                    [__weakSelf.newsTableView reloadData];
                } else {
                    [NSObject showAllTextDialog:@"No more News" xOffset:0.0 yOffset:200.0];
                }
            }

        });
    }];
}

#pragma mark - Setter & Getter

- (UITableView *)newsTableView {
    if (!_newsTableView) {
        _newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 49) style:UITableViewStylePlain];
        _newsTableView.dataSource = self;
        _newsTableView.delegate = self;
        _newsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        _newsTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    }
    return _newsTableView;
}

- (News *)news {
    if (!_news) {
        _news = [[News alloc] initWithType:NewsViewTypeNews];
    }
    return _news;
}

- (NSMutableArray *)newsArr {
    if (!_newsArr) {
        _newsArr = [[NSMutableArray alloc] init];
    }
    return _newsArr;
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
