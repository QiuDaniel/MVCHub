//
//  WebViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/7.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) NSString *titleString;

@end

@implementation WebViewController

#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.request = params[@"request"];
        self.titleString = params[@"title"];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;

    [self.view addSubview:self.webView];
    [self.webView loadRequest:self.request];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleViewType = TitleViewTypeLoadingTitle;
    self.title = self.titleString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeOther) {
        if ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"]) {
           // self.titleViewType = TitleViewTypeLoadingTitle;
        }
        return YES;
    } else {
        [UIApplication.sharedApplication openURL:request.URL];
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.titleViewType = TitleViewTypeDefault;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.titleViewType = TitleViewTypeDefault;
}



#pragma mark - Getter
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:kScreen_Bounds];
        _webView.delegate = self;
    }
    return _webView;
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
