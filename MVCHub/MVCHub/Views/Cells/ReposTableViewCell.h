//
//  ReposTableViewCell.h
//  MVCHub
//
//  Created by daniel on 2016/11/8.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReposTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel, *updateTimeLabel, *desLabel, *languageLabel, *forkCountLabel, *starCountLabel;
@end
