//
//  CountryAndLanguageViewController.h
//  MVCHub
//
//  Created by daniel on 2016/11/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "SegmentedControlController.h"

typedef void(^CallbackBlock)(NSDictionary *);

@interface CountryAndLanguageViewController : SegmentedControlController

@property (nonatomic, copy) CallbackBlock callback;

@end
