//
//  SourceEditorViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/5.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "SourceEditorViewController.h"

@interface SourceEditorViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

@property (nonatomic, strong) OCTRef *reference;
@property (nonatomic, strong) OCTRepository *repository;
@property (nonatomic, assign) SourceEditorVCEntry entry;

@property (nonatomic, copy) NSString *HTMLString, *titleString;

@end

@implementation SourceEditorViewController

#pragma mark - Init
- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super initWithParams:params];
    if (self) {
        self.reference = params[@"reference"];
        self.repository = params[@"repository"];
        self.entry = [params[@"entry"] integerValue];
        self.titleString = params[@"title"];
        self.HTMLString = params[@"HTMLString"];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.titleString;
    [self setupNavBtn];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

#pragma mark - Overwritten Method
- (void)setupNavBtn {
    [super setupNavBtn];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:nil
                                                                          action:nil];
}

#pragma mark - Private Method
- (void)reloadData {
    NSString *domain = [OCTServer dotComServer].baseWebURL.absoluteString;
    NSString *ownerLogin = self.repository.ownerLogin;
    NSString *name = self.repository.name;
    NSString *branch = [self.reference.name componentsSeparatedByString:@"/"].lastObject;
    NSString *URLString = [NSString stringWithFormat:@"%@/%@/%@/raw/%@/", domain, ownerLogin, name, branch];
    NSURL *baseURL = [NSURL URLWithString:URLString];
    [self.webView loadHTMLString:[kMVCReadmeCSSStyle stringByAppendingString:self.HTMLString] baseURL:baseURL];
}

#pragma mark - Getter
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:kScreen_Bounds];
        _webView.backgroundColor = [UIColor whiteColor];
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
