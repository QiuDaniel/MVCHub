//
//  RepoReadmeTableViewCell.h
//  MVCHub
//
//  Created by daniel on 2016/10/25.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepoReadmeTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *readmeButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIWebView *webView;

@end
