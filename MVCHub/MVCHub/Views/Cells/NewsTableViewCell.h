//
//  NewsTableViewCell.h
//  MVCHub
//
//  Created by daniel on 2016/10/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsAvatarButtonDelegate <NSObject>

- (void)tapAvatarButton:(UIButton *)btn ;

@end

@interface NewsTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *avatarButton;

@property (nonatomic, strong) YYLabel *detailLabel;
@property (nonatomic, weak) id<NewsAvatarButtonDelegate> delegate;

@end
