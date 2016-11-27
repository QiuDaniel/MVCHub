//
//  SegmentedControlController.m
//  MVCHub
//
//  Created by daniel on 2016/11/22.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "SegmentedControlController.h"


@interface SegmentedControlController ()

@property (nonatomic, strong, readwrite) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation SegmentedControlController

#pragma mark - Init
- (void)initialize {
    UIViewController *currentViewController = self.viewControllers.firstObject;
    [self addChildViewController:currentViewController];
    currentViewController.view.frame = self.view.bounds;
    [self.view addSubview:currentViewController.view];
    [currentViewController didMoveToParentViewController:self];
    
    self.currentViewController = currentViewController;
    
    NSArray *items = [self.viewControllers.rac_sequence map:^(UIViewController *viewController) {
        return viewController.segmentedControlItem;
    }].array;
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(didClickedControlAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Response Event
- (void)didClickedControlAction:(UISegmentedControl *)segmentedControl {
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    UIViewController *toViewController = self.viewControllers[selectedSegmentIndex];
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    toViewController.view.frame = self.view.bounds;
    @weakify(self)
    [self transitionFromViewController:self.currentViewController
                      toViewController:toViewController
                              duration:0
                               options:0
                            animations:nil
                            completion:^(BOOL finished) {
                                @strongify(self)
                                [ self.currentViewController removeFromParentViewController];
                                [toViewController didMoveToParentViewController:self];
                                self.currentViewController = toViewController;
                                
                                if ([self.delegate respondsToSelector:@selector(segmentedControlController:didSelectViewController:)]) {
                                    [self.delegate segmentedControlController:self didSelectViewController:toViewController];
                                }
                            }];

}

#pragma mark - Getter & Setter

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    [self initialize];
}

@end

static void *SegmentedControlItemKey = &SegmentedControlItemKey;

@implementation UIViewController (SegmentedControlItem)

- (NSString *)segmentedControlItem {
    return objc_getAssociatedObject(self, SegmentedControlItemKey);
}

- (void)setSegmentedControlItem:(NSString *)segmentedControlItem {
    objc_setAssociatedObject(self, SegmentedControlItemKey, segmentedControlItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
