//
//  LanguageViewController.h
//  MVCHub
//
//  Created by daniel on 2016/11/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CallBackBlock)(NSDictionary *);

@interface LanguageViewController : BaseViewController

@property (nonatomic, copy) CallBackBlock callback;
@property (nonatomic, copy) NSDictionary *item;


- (NSString *)resourceName;

@end
