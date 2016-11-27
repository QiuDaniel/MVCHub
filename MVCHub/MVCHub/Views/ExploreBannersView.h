//
//  ExploreBannersView.h
//  MVCHub
//
//  Created by daniel on 2016/11/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Showcase;

typedef void(^tapActionBlock)(Showcase *showcase);

@interface ExploreBannersView : UIView
@property (nonatomic, copy) NSArray *curBannerList;
@property (nonatomic, copy) tapActionBlock tapActionBlock;

- (void)reloadData;
@end
