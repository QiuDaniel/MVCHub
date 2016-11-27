//
//  ExploreTableViewCell.h
//  MVCHub
//
//  Created by daniel on 2016/11/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExploreTableViewCellDelegate <NSObject>

- (void)buttonClicked:(UIButton *)btn;

@end

@interface ExploreTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *seeAllButton;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, assign) NSInteger section;

@property (nonatomic, weak) id<ExploreTableViewCellDelegate> delegate;

- (void)setModelArray:(NSArray *)array;
@end
