//
//  OAuthLoginViewController.h
//  MVCHub
//
//  Created by daniel on 2016/12/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^Callback)(NSString *);

@interface OAuthLoginViewController : BaseViewController

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) Callback callback;

@end
