//
//  FeedbackViewController.m
//  MVCHub
//
//  Created by daniel on 2016/11/24.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@property (nonatomic, strong) UITextView *feedbackTextView;

@end

@implementation FeedbackViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xefeff4"];
    self.title = @"Feedback";
    [self.view addSubview:self.feedbackTextView];
    [self.feedbackTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 150));
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(86);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.feedbackTextView becomeFirstResponder];
}
#pragma mark - Overwritten Method
- (void)setupNavBtn {
    [super setupNavBtn];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitButtonClicked)];
    rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"0x24AFFC"];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - Response Event
- (void)submitButtonClicked {
    DebugLog(@"提交");
#warning mvcHub还未提交到github，此功能还不能使用;
    OCTRepository *mvcHub = [OCTRepository modelWithDictionary:@{
                                                                 @"ownerLogin":kMVCHub_Owner_Login,
                                                                 @"name":@""} error:nil];
    __block MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    progressHUD.labelText = @"Submitting...";
    @weakify(self)
    [[MVCHubAPIManager sharedManager] createIssueWithTitle:[NSString stringWithFormat:@"%@ from %@", self.title, [OCTUser mvc_currentUser].login] content:self.feedbackTextView.text inRepository:mvcHub andBlock:^(NSNumber *state, NSError *error) {
      @strongify(self)
        if ([state boolValue]) {
            progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
            progressHUD.mode = MBProgressHUDModeCustomView;
            progressHUD.labelText = @"Submitted";
            
            [progressHUD hide:YES afterDelay:3];
        } else {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            DebugLogError(error);
        }
    }];
}

#pragma mark - Getter
- (UITextView *)feedbackTextView {
    if (!_feedbackTextView) {
        _feedbackTextView = ({
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
            textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
            textView;
        });
    }
    return _feedbackTextView;
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
