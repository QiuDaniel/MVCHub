//
//  ExploreTableViewCell.m
//  MVCHub
//
//  Created by daniel on 2016/11/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ExploreTableViewCell.h"
#import "ExploreCollectionViewCell.h"
#import "Explore.h"
#import "RepoDetailViewController.h"
#import "UserDetailViewController.h"

@interface ExploreTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

static NSString *const ExploreCollectionCell = @"ExploreCollectionViewCell";

@implementation ExploreTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.top.equalTo(self.contentView).offset(15);
        }];
        
        [self.contentView addSubview:self.seeAllButton];
        [self.seeAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-10);
            make.baseline.equalTo(self.titleLabel);
        }];
        
        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Collection Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ExploreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ExploreCollectionCell forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if (self.dataArray.count > 0) {
        cell.nameLabel.text = ((Explore *)self.dataArray[indexPath.row]).name;
        [cell.avatarImageView sd_setImageWithURL:((Explore *)self.dataArray[indexPath.row]).ownerAvatarURL placeholderImage:[[UIColor colorWithHexString:@"0xEDEDED"] color2ImageSized:cell.avatarImageView.frame.size]];
    }
    
    return cell;
}

#pragma mark - CollectionDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 104);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}
#pragma mark - Collection Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"点击了第%ld个",indexPath.row);
    if (self.section == 0 || self.section == 1) {
        RepoDetailViewController *repoDetailVC = [[RepoDetailViewController alloc] initWithParams:@{@"repository":((Explore *)self.dataArray[indexPath.row]).object }];
        [self.navigationController pushViewController:repoDetailVC animated:YES];
    } else if (self.section == 2) {
        UserDetailViewController *userDetailVC = [[UserDetailViewController alloc] initWithParams:@{@"user":((Explore *)self.dataArray[indexPath.row]).object}];
        [self.navigationController pushViewController:userDetailVC animated:YES];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Response Event

- (void)clickSeeAllBtn:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(buttonClicked:)]) {
        [self.delegate performSelector:@selector(buttonClicked:) withObject:btn];
    }
    
}

#pragma mark - Public Method
- (void)setModelArray:(NSArray *)array{
    for (id object in array) {
        [self.dataArray addObject:[[Explore alloc] initWithObject:object]];
    }
    [self.collectionView reloadData];
}

#pragma mark -  Getter & Setter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = @"Trending repositories this week";
            label.font = [UIFont systemFontOfSize:15.0];
            label;
        });
    }
    return _titleLabel;
}

- (UIButton *)seeAllButton {
    if (!_seeAllButton) {
        _seeAllButton = ({
            UIButton *button = [[UIButton alloc] init];
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
            [title appendAttributedString:[[NSAttributedString alloc] initWithString:@"See all "
                                                                          attributes:@{
                                                                                                             NSFontAttributeName:[UIFont systemFontOfSize:13],
                                                                                                             NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0x4a4a4a"]
                                                                                                             }]];
            [title appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString octicon_iconStringForEnum:OCTIconChevronRight]
                                                                          attributes:@{
                                                                                                                                                           NSFontAttributeName:[UIFont fontWithName:kOcticonsFamilyName size:13],
                                                                                                                                                           NSForegroundColorAttributeName:[UIColor lightGrayColor]
                                                                                                                                                           }]];
            [button setAttributedTitle:[title mutableCopy] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clickSeeAllBtn:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _seeAllButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 104) collectionViewLayout:layout];
            [view registerClass:[ExploreCollectionViewCell class] forCellWithReuseIdentifier:ExploreCollectionCell];
            view.backgroundColor = [UIColor whiteColor];
            view.contentMode = UIViewContentModeScaleToFill;
            view.showsHorizontalScrollIndicator = NO;
            view.showsVerticalScrollIndicator = NO;
            view.delegate = self;
            view.dataSource = self;
            view;
        });
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
@end
