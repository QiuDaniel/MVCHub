//
//  ExploreBannersView.m
//  MVCHub
//
//  Created by daniel on 2016/11/17.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ExploreBannersView.h"
#import "SMPageControl.h"
#import "AutoSlideScrollView.h"
#import "YLImageView.h"
#import "Showcase.h"

@interface ExploreBannersView ()

@property (nonatomic, assign) CGFloat   padding_top, padding_bottom, image_width, ratio;
@property (nonatomic, strong) UILabel *typeLabel, *titleLabel;
@property (nonatomic, strong) SMPageControl *myPageControl;
@property (nonatomic, strong) AutoSlideScrollView *mySlideView;
@property (nonatomic, strong) NSMutableArray *imageViewList;

@end

@implementation ExploreBannersView

- (instancetype)init
{
    
    self = [super init];
    if (self) {
        self.backgroundColor = kColorTableBG;
        _padding_top = 0;
        _padding_bottom = 40;
        _image_width = kScreen_Width;
        _ratio = 0.4;
        CGFloat viewHeight = _padding_top + _padding_bottom + _image_width * _ratio;
        [self setSize:CGSizeMake(kScreen_Width, viewHeight)];
        [self addLineUp:NO andDown:YES];
    }
    return self;
}

- (void)setCurBannerList:(NSArray *)curBannerList{
    if ([[_curBannerList valueForKey:@"name"] isEqualToArray:[curBannerList valueForKey:@"name"]]) {
        return;
    }
    _curBannerList = curBannerList;
    if (!_mySlideView) {
        _mySlideView = ({
            __weak typeof(self) weakSelf = self;
            AutoSlideScrollView *slideView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, _padding_top, _image_width, _image_width * _ratio) animationDuration:5.0];
            slideView.layer.masksToBounds = YES;
            slideView.scrollView.scrollsToTop = NO;
            
            slideView.totalPagesCount = ^NSInteger(){
                return weakSelf.curBannerList.count;
            };
            slideView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                if (weakSelf.curBannerList.count > pageIndex) {
                    YLImageView *imageView = [weakSelf p_reuseViewForIndex:pageIndex];
                    Showcase *showcase = weakSelf.curBannerList[pageIndex];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:showcase.image_url]];
                    return imageView;
                }else{
                    //return [UIView new];
                    UIImageView *imageView = [[UIImageView alloc] init];
                    imageView.image = [[UIColor colorWithHexString:@"0xEDEDED"] color2Image];
                    return imageView;
                }
            };
            slideView.currentPageIndexChangeBlock = ^(NSInteger currentPageIndex){
                if (weakSelf.curBannerList.count > currentPageIndex) {
                    Showcase *showcase = weakSelf.curBannerList[currentPageIndex];
                    weakSelf.typeLabel.text = showcase.name;
                    weakSelf.titleLabel.text = showcase.description_mine;
                }else{
                    weakSelf.typeLabel.text = weakSelf.titleLabel.text = @"...    ";
                }
                weakSelf.myPageControl.currentPage = currentPageIndex;
            };
            slideView.tapActionBlock = ^(NSInteger pageIndex){
                if (weakSelf.tapActionBlock && weakSelf.curBannerList.count > pageIndex) {
                    weakSelf.tapActionBlock(weakSelf.curBannerList[pageIndex]);
                }
            };
            slideView;
        });
        [self addSubview:_mySlideView];
    }
    if (!_myPageControl) {
        _myPageControl = ({
            SMPageControl *pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 30, _mySlideView.bottom + (40 - 10)/2, 30, 10)];
            pageControl.userInteractionEnabled = NO;
            pageControl.backgroundColor = [UIColor clearColor];
            pageControl.pageIndicatorImage = [UIImage imageNamed:@"banner__page_unselected"];
            pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"banner__page_selected"];
            pageControl.numberOfPages = _curBannerList.count;
            pageControl.currentPage = 0;
            pageControl.alignment = SMPageControlAlignmentRight;
            pageControl;
        });
        [self addSubview:_myPageControl];
    }
    
    if (!_typeLabel) {
        _typeLabel = ({
            UILabel *label = [UILabel labelWithFont:[UIFont boldSystemFontOfSize:10] textColor:[UIColor colorWithHexString:@"0x666666"]];
            [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [label doBorderWidth:0.5 color:nil cornerRadius:2.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"活动    ";
            label;
        });
        _typeLabel.text = [(Showcase *)_curBannerList.firstObject name];
        [self addSubview:_typeLabel];
    }
    
    if (!_titleLabel) {
        _titleLabel =  [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:[UIColor colorWithHexString:@"0x222222"]];
        _titleLabel.text = [(Showcase *)_curBannerList.firstObject description_mine];
        [self addSubview:_titleLabel];
    }
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kPaddingLeftWidth);
        make.centerY.equalTo(_myPageControl);
        make.height.mas_equalTo(18);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_typeLabel.mas_right).offset(5);
        make.right.equalTo(_myPageControl.mas_left).offset(-5);
        make.centerY.equalTo(_myPageControl);
    }];
    [self reloadData];
    DebugLog(@"%@", _curBannerList);
}

- (YLImageView *)p_reuseViewForIndex:(NSInteger)pageIndex{
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            YLImageView *view = [[YLImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, _padding_top, _image_width, _image_width * _ratio)];
            view.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
            view.clipsToBounds = YES;
            view.contentMode = UIViewContentModeScaleAspectFill;
            [_imageViewList addObject:view];
        }
    }
    YLImageView *imageView;
    NSInteger currentPageIndex = self.mySlideView.currentPageIndex;
    if (pageIndex == currentPageIndex) {
        imageView = _imageViewList[1];
    }else if (pageIndex == currentPageIndex + 1
              || (labs(pageIndex - currentPageIndex) > 1 && pageIndex < currentPageIndex)){
        imageView = _imageViewList[2];
    }else{
        imageView = _imageViewList[0];
    }
    return imageView;
}

- (void)reloadData{
    self.hidden = _curBannerList.count <= 0;
    if (_curBannerList.count <= 0) {
        return;
    }
    
    NSInteger currentPageIndex = MIN(self.mySlideView.currentPageIndex, _curBannerList.count - 1) ;
    Showcase *showcase = _curBannerList[currentPageIndex];
    _titleLabel.text = showcase.description_mine;
    _typeLabel.text = showcase.name;
    
    _myPageControl.numberOfPages = _curBannerList.count;
    _myPageControl.currentPage = currentPageIndex;
    
    [_mySlideView reloadData];
}

@end
