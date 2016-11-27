//
//  RepoDetailViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/24.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RepoDetailViewController.h"
#import "RepoReadmeTableViewCell.h"
#import "RepoStatisticsTableViewCell.h"
#import "RepoViewCodeTableViewCell.h"
#import "RepoDetail.h"
#import "GitTreeViewController.h"
#import "SelectBranchOrTagViewController.h"
#import "BaseNavigationController.h"
#import "RepoSettingsViewController.h"
#import "SourceEditorViewController.h"
#import "TTTTimeIntervalFormatter.h"


@interface RepoDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
@property (nonatomic, strong) UITableView *repoDetailTableView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) RepoReadmeTableViewCell *readmeTableViewCell;
@property (nonatomic, strong) OCTRepository *repository;

//@property (nonatomic, strong) RepoDetail *repoDetail;

@property (nonatomic, copy, readwrite) NSArray *references;
@property (nonatomic, strong) OCTRef *reference;

@property (nonatomic, copy, readwrite) NSString *referenceName, *HTMLString, *summaryReadmeHTML;

@end

static NSString *const RepoReadmeCell = @"RepoReadmeTableViewCell";
static NSString *const RepoStatisticsCell = @"RepoStatisticsTableViewCell";
static NSString *const RepoViewCodeCell = @"RepoViewCodeTableViewCell";

@implementation RepoDetailViewController

#pragma mark - Init

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        id repository = params[@"repository"];
        if ([repository isKindOfClass:[OCTRepository class]]) {
            _repository = params[@"repository"];
        } else if ([repository isKindOfClass:[NSDictionary class]]) {
            _repository = [OCTRepository modelWithDictionary:repository error:nil];
        }
        
        NSParameterAssert(_repository);
        _referenceName = params[@"referenceName"] ?: ReferenceNameWithBranchName(_repository.defaultBranch);
        
        NSParameterAssert(_referenceName);
        NSError *error = nil;
        _reference = [[OCTRef alloc] initWithDictionary:@{@"name": _referenceName} error:&error];
        if (error) DebugLogError(error);
        
        self.HTMLString = (NSString *)[[YYCache sharedCache] objectForKey:[YYCache cacheKeyForReadmeWithRepository:_repository reference:_reference.name mediaType:OCTClientMediaTypeHTML]];
        _summaryReadmeHTML = [NSString summaryReadmeHTMLFromReadmeHTML:self.HTMLString];
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.repoDetailTableView];
    [self.repoDetailTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 44, 0));
    }];
    [self.repoDetailTableView registerClass:[RepoReadmeTableViewCell class] forCellReuseIdentifier:RepoReadmeCell];
    [self.repoDetailTableView registerClass:[RepoStatisticsTableViewCell class] forCellReuseIdentifier:RepoStatisticsCell];
    [self.repoDetailTableView registerClass:[RepoViewCodeTableViewCell class] forCellReuseIdentifier:RepoViewCodeCell];
    [self.view addSubview:self.toolbar];
    self.titleViewType = TitleViewTypeDoubleTitle;
    [self.readmeTableViewCell.activityIndicatorView startAnimating];
    [self loadRepoData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavBtn];
    [self setupToolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 58;
        case 1:
            return UITableViewAutomaticDimension;
        case 2:
            return 77;
        case 3:
            return 40 + CGRectGetHeight(self.readmeTableViewCell.webView.frame) + 40;
        default:
            return 44;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 0.01;
    }
    return 7.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) return 0.01;
    if (section == 3) return 15;
    return 7.5;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}
#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DefaultCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        RepoStatisticsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RepoStatisticsCell forIndexPath:indexPath];
        cell.forkLabel.text = [@(self.repository.forksCount) stringValue];
        cell.watchLabel.text = [@(self.repository.subscribersCount) stringValue];
        @weakify(cell)
        [[RACObserve(self.repository, stargazersCount)
          deliverOnMainThread]
          subscribeNext:^(NSNumber *stargazersCount) {
              @strongify(cell)
              cell.starLabel.text = [stargazersCount stringValue];
         }];
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.repository.repoDescription;
        cell.textLabel.textColor = [UIColor blackColor];
        return cell;

    } else if (indexPath.section == 2) {
        RepoViewCodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RepoViewCodeCell forIndexPath:indexPath];
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        timeIntervalFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [[[RACObserve(self.repository, dateUpdated) ignore:nil] map:^id(NSDate *dateUpdated) {
            return [NSString stringWithFormat:@"Updated %@", [timeIntervalFormatter stringForTimeIntervalFromDate:NSDate.date toDate:dateUpdated]];
        }] subscribeNext:^(NSString *dateUpdated) {
            cell.timeLabel.text = dateUpdated;
        }];

        [cell.viewCodeButton setImage:[UIImage octicon_imageWithIcon:@"FileDirectory"
                                                     backgroundColor:[UIColor clearColor]
                                                           iconColor:[UIColor colorWithHexString:@"0x4183C4"]
                                                           iconScale:1
                                                             andSize:CGSizeMake(22, 22)]
                             forState:UIControlStateNormal];
        [cell.viewCodeButton addTarget:self action:@selector(clickViewCodeButton) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else if (indexPath.section == 3) {
        RepoReadmeTableViewCell *cell = self.readmeTableViewCell;
        [cell.readmeButton addTarget:self action:@selector(clickReadmeButton) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    return cell;
}

#pragma mark - WebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //self.readmeTableViewCell.webView.hidden = YES;
//    [self.readmeTableViewCell.activityIndicatorView startAnimating];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.readmeTableViewCell.webView.hidden = NO;
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    CGRect webViewFrame = webView.frame;
    webViewFrame.size.height = height + 3;
    webView.frame = webViewFrame;
    [self.repoDetailTableView reloadData];
    [self.readmeTableViewCell.activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return self.navigationController.topViewController == self;
}
#pragma mark - Response Event

- (void)clickRightBarButton {
    RepoSettingsViewController *repoSettingsVC = [[RepoSettingsViewController alloc] initWithParams:@{@"repository":self.repository}];
    [self.navigationController pushViewController:repoSettingsVC animated:YES];
}

- (void)clickViewCodeButton {
    GitTreeViewController *gitTreeVC = [[GitTreeViewController alloc] initWithParams:@{
                                                                                      @"repository":self.repository,
                                                                                      @"reference":self.reference
                                                                                      }];
    [self.navigationController pushViewController:gitTreeVC animated:YES];
}

- (void)clickReadmeButton {
    DebugLog(@"点击了Readme");
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:self.HTMLString forKey:@"HTMLString"];
    [params setValue:@"README.md" forKey:@"title"];
    [params setValue:self.repository forKey:@"repository"];
    [params setValue:self.reference forKey:@"reference"];
    [params setValue:@(SourceEditorVCEntryRepoDetail) forKey:@"entry"];
    SourceEditorViewController *sourceEditorVC = [[SourceEditorViewController alloc] initWithParams:params];
    [self.navigationController pushViewController:sourceEditorVC animated:YES];
}

- (void)clickToolbarButton {
    if (self.references) {
        [self presentSelectBranchOrTagModalView];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Loading Branches & Tags...";
        @weakify(self)
        [[MVCHubAPIManager sharedManager] requestAllReferencesInRepository:self.repository andBlcok:^(id data, NSError *error) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            if (data) {
                self.references = (NSArray *)data;
                [self presentSelectBranchOrTagModalView];
            }
        }];
    }
}
#pragma mark - Overwritten Method
- (void)setupNavBtn {
    [super setupNavBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(clickRightBarButton)];
}

#pragma mark - Private Method
- (void)setupToolbar {
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 44));
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitleColor:[UIColor colorWithHexString:@"0x30434E"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button addTarget:self action:@selector(clickToolbarButton) forControlEvents:UIControlEventTouchUpInside];
    @weakify(self)
    [RACObserve(self, reference) subscribeNext:^(OCTRef *reference) {
        @strongify(self)
        [button setTitle:[self.reference.name componentsSeparatedByString:@"/"].lastObject forState:UIControlStateNormal];
        [button setImage:[UIImage octicon_imageWithIcon:[reference octiconIdentifier]
                                        backgroundColor:[UIColor clearColor]
                                              iconColor:[UIColor colorWithHexString:@"0x30434E"]
                                              iconScale:1
                                                andSize:CGSizeMake(23, 23)] forState:UIControlStateNormal];
        [button sizeToFit];
    }];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.toolbar.items = @[ barButtonItem ];
    
}

- (void)presentSelectBranchOrTagModalView {
    NSDictionary *params = @{
                             @"references":self.references,
                             @"selectedReference":self.reference
                                 };
    SelectBranchOrTagViewController *selectBranchOrTagVC = [[SelectBranchOrTagViewController alloc] initWithParams:params];
    MVCWeakSelf
    selectBranchOrTagVC.callback = ^(OCTRef *reference) {
        __weakSelf.reference = reference;
        [__weakSelf loadReadmeHTML];
    };
    
    BaseNavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:selectBranchOrTagVC];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navi animated:YES completion:nil];
    });
}

#pragma mark - Request API
- (void)loadRepoData {
    MVCWeakSelf
    [[MVCHubAPIManager sharedManager] requestRepositoryWithName:self.repository.name owner:self.repository.ownerLogin andBlock:^(id data, NSError *error) {
        OCTRepository *tempRepo = (OCTRepository *)data;
        [__weakSelf willChangeValueForKey:@"repository"];
        
        tempRepo.starredStatus = __weakSelf.repository.starredStatus;
        [__weakSelf.repository mergeValuesForKeysFromModel:tempRepo];
        
        [__weakSelf didChangeValueForKey:@"repository"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf.repoDetailTableView reloadData];
            RAC(__weakSelf.doubleTitleView.titleLabel, text)    = RACObserve(__weakSelf.repository, name);
            RAC(__weakSelf.doubleTitleView.subtitleLabel, text) = RACObserve(__weakSelf.repository, ownerLogin);
            
            [[__weakSelf
              rac_signalForSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]
             subscribeNext:^(id x) {
                 __weakSelf.doubleTitleView.titleLabel.text    = __weakSelf.repository.name;
                 __weakSelf.doubleTitleView.subtitleLabel.text = __weakSelf.repository.ownerLogin;
             }];

        });
    }];
    [self loadReadmeHTML];
}

- (void)loadReadmeHTML {
    MVCWeakSelf
    [[MVCHubAPIManager sharedManager] requestRepositoryReadmeWithRepository:self.repository reference:self.reference.name andBlock:^(id data, NSError *error) {
        [__weakSelf.readmeTableViewCell.webView loadHTMLString:data baseURL:nil];
    }];
}

#pragma mark - Getter
- (UITableView *)repoDetailTableView {
    if (!_repoDetailTableView) {
        _repoDetailTableView = [[UITableView alloc] initWithFrame:kScreen_Bounds style:UITableViewStylePlain];
        _repoDetailTableView.dataSource = self;
        _repoDetailTableView.delegate = self;
        _repoDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _repoDetailTableView.estimatedRowHeight = 44.0;
        _repoDetailTableView.backgroundColor = [UIColor whiteColor];

        //_repoDetailTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadRepoData)];
    }
    return _repoDetailTableView;
}

- (RepoReadmeTableViewCell *)readmeTableViewCell {
    if(!_readmeTableViewCell) {
        _readmeTableViewCell = [[RepoReadmeTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RepoReadmeCell];
        _readmeTableViewCell.webView.delegate = self;
    }
    return _readmeTableViewCell;
}

- (UIToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    }
    return _toolbar;
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
