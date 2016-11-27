//
//  SelectBranchOrTagViewController.h
//  MVCHub
//
//  Created by daniel on 2016/11/5.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^VoidBlock_id)(id);

@interface SelectBranchOrTagViewController : BaseViewController

@property(nonatomic, copy) VoidBlock_id callback;

- (instancetype)initWithParams:(NSDictionary *)params;

@end
