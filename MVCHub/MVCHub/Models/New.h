//
//  New.h
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface New : NSObject

@property (nonatomic, strong) OCTEvent *event;
@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) YYTextLayout *textLayout;

- (instancetype)initWithEvent:(OCTEvent *) event;


@end
