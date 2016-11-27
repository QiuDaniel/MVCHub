//
//  LoginViewController.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "LoginViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"
#import "Login.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

@interface LoginViewController () <UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) Login *myLogin;
@property (nonatomic, strong) TPKeyboardAvoidingTableView *loginTableView;
@property (nonatomic, strong) UIView *headerView, *bottomView;
@property (nonatomic, strong) UIButton *loginBtn, *avatarBtn;
@end

@implementation LoginViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myLogin = [[Login alloc] init];
    if ([SSKeychain rawLogin] != nil) {
        self.myLogin.username = [SSKeychain rawLogin];
        self.myLogin.password = [SSKeychain password];
    }
    
    
    self.loginTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    self.loginTableView.tableHeaderView = [self customHeaderView];
    self.loginTableView.tableFooterView = [self customFooterView];
    [self configBottomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text forIndexPath:indexPath];
    cell.isForLoginVC = YES;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    MVCWeakSelf
    if (indexPath.row == 0) {
        cell.iconImageView.image = [UIImage octicon_imageWithIcon:@"Person"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor darkGrayColor]
                                                        iconScale:1.0
                                                          andSize:CGSizeMake(22, 22)];
        cell.textFiled.keyboardType = UIKeyboardTypeDefault;
        [cell setPlaceholder:@" GitHub username or email" value:self.myLogin.username];
        cell.textValueChangedBlock = ^(NSString *valueStr) {
            __weakSelf.myLogin.username = valueStr;
        };
    }else if (indexPath.row == 1) {
        cell.iconImageView.image = [UIImage octicon_imageWithIcon:@"Lock"
                                                  backgroundColor:[UIColor clearColor]
                                                        iconColor:[UIColor darkGrayColor]
                                                        iconScale:1.0
                                                          andSize:CGSizeMake(22, 22)];
        [cell setPlaceholder:@" GitHub password" value:self.myLogin.password];
        cell.textFiled.secureTextEntry = YES;
        cell.textValueChangedBlock = ^(NSString *valueStr) {
            __weakSelf.myLogin.password = valueStr;
        };
    }
    return cell;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarBtn.imageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.avatarBtn.imageView];
    }
    return nil;
}


#pragma mark - Event Response
- (void)avatarBtnClicked {
    MVCSharedAppDelegate.window.backgroundColor = [UIColor blackColor];
    
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:[self.avatarBtn imageForState:UIControlStateNormal]];
    viewController.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    viewController.transitioningDelegate = self;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)doLogin {
    DebugLog(@"点击了登录");
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES].
        labelText = @"Logging in...";
    MVCWeakSelf
    self.loginBtn.enabled = NO;
    [[MVCHubAPIManager sharedManager] requestLoginWithUsername:self.myLogin.username
                                                      password:self.myLogin.password
                                               oneTimePassword:nil
                                                        scopes:OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesRepository
                                                      andBlock:^(OCTClient *authenticatedClient, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            __weakSelf.loginBtn.enabled = YES;
            if (authenticatedClient) {
                [Login logIn:authenticatedClient];
                SSKeychain.rawLogin = authenticatedClient.user.rawLogin;
                SSKeychain.password = __weakSelf.myLogin.password;
                SSKeychain.accessToken = authenticatedClient.token;
                [MVCSharedAppDelegate setupTabViewController];
            }else {
                if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorAuthenticationFailed) {
                    [NSObject showStatusBarErrorStr:@"Incorrect username or password"];
                }else if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
                    NSString *message = @"Please enter the 2FA code you received via SMS or read from an authenticator app";
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kAlert_Title
                                                                                             message:message
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.returnKeyType = UIReturnKeyGo;
                        textField.placeholder = @"2FA code";
                        textField.secureTextEntry = YES;
                    }];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                }
            }
        });
    }];

}

- (void)goBrowserVC:(UIButton *)btn {
    
}

#pragma mark - TableView Header & Footer

- (UIView *)customHeaderView {
    CGFloat avatarWidth;
    if (kDevice_Is_iPhone6Plus) {
        avatarWidth = 100;
    }else if (kDevice_Is_iPhone6) {
        avatarWidth = 90;
    }else {
        avatarWidth = 75;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height / 3)];
    self.avatarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, avatarWidth, avatarWidth)];
    self.avatarBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarBtn.layer.borderWidth = 2.0f;
    self.avatarBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [headerView addSubview:self.avatarBtn];
    [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(avatarWidth, avatarWidth));
        make.centerX.equalTo(headerView);
        make.centerY.equalTo(headerView).offset(30);
    }];

    RAC(self, myLogin.avatarURL) = [[RACObserve(self, myLogin.username) map:^(NSString *username) {
        return [[OCTUser mvc_fetchUserWithRawLogin:username] avatarURL];
    }] distinctUntilChanged];
    MVCWeakSelf
    [RACObserve(self, myLogin.avatarURL) subscribeNext:^(NSURL *avatarURL) {
        [__weakSelf.avatarBtn sd_setImageWithURL:self.myLogin.avatarURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    }];
    
    [self.avatarBtn addTarget:self action:@selector(avatarBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    return  headerView;
}

- (UIView *)customFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height / 2)];
    self.loginBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"Log In" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width - kLoginPaddingLeftWidth * 2, 45) target:self action:@selector(doLogin)];
    [footerView addSubview:self.loginBtn];
    RAC(self, loginBtn.enabled) = [[RACSignal combineLatest:@[RACObserve(self, myLogin.username),
                                                              RACObserve(self, myLogin.password)]
                                                     reduce:^id(NSString *username,
                                                                NSString *password){
                                                         return @((username &&username.length > 0) && (password && password.length > 0));
                                                     }] distinctUntilChanged];
    return footerView;
}


#pragma mark BottomView
- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 55, kScreen_Width, 55)];
        _bottomView.backgroundColor = [UIColor clearColor];
        UIButton *browserBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width / 2, 30)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:[UIColor colorWithRed:0.34 green:0.42 blue:0.46 alpha:1.0] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
            
            [button setTitle:@"OAuth2 Authorization Login" forState:UIControlStateNormal];
            [_bottomView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kScreen_Width / 2, 30));
                make.centerX.equalTo(_bottomView);
                make.top.equalTo(_bottomView);
            }];
            button;
        });
        [browserBtn addTarget:self action:@selector(goBrowserVC:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bottomView];
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
