//
//  SegmentedControlController.h
//  MVCHub
//
//  Created by daniel on 2016/11/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "BaseViewController.h"

@class SegmentedControlController;

@protocol SegmentedControlControllerDelegate <NSObject>

@optional

- (void)segmentedControlController:(SegmentedControlController *)segmentedContrlController didSelectViewController:(UIViewController *)viewController;

@end

@interface SegmentedControlController : BaseViewController

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) id<SegmentedControlControllerDelegate> delegate;

@end

@interface UIViewController (SegmentedControlItem)

@property (nonatomic, copy) NSString *segmentedControlItem;

@end
