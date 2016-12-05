//
//  OAuthLoginViewController.m
//  MVCHub
//
//  Created by daniel on 2016/12/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OAuthLoginViewController.h"
#import "OAuthLogin.h"

@interface OAuthLoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) OAuthLogin *oAuthLogin;

@end

@implementation OAuthLoginViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:self.oAuthLogin.request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DebugLog(@"URL=====>%@",request.URL);
    if ([request.URL.scheme isEqualToString:kMVC_URL_SCHEME]) {
        NSDictionary *queryArguments = request.URL.oct_queryArguments;
        if ([queryArguments[@"state"] isEqualToString:self.oAuthLogin.UUIDString]) {
            if (self.callback) {
                self.callback(queryArguments[@"code"]);
            }
        }
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeOther) {
        if ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"]) {
            self.titleViewType = TitleViewTypeLoadingTitle;
        }
        return YES;
    } else {
        //[[UIApplication sharedApplication] openURL:request.URL];
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.titleViewType = TitleViewTypeDefault;
    self.title = self.oAuthLogin.title;
}

#pragma mark - Getter
- (UIWebView *)webView {
    if (!_webView) {
        _webView = ({
            UIWebView *view = [[UIWebView alloc] initWithFrame:kScreen_Bounds];
            view.delegate = self;
            view;
        });
    }
    return _webView;
}

- (OAuthLogin *)oAuthLogin {
    if (!_oAuthLogin) {
        _oAuthLogin = [[OAuthLogin alloc] init];
    }
    return _oAuthLogin;
}
@end
