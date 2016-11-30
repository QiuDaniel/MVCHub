//
//  RootTabViewController.h
//  NetMananerEngineer
//
//  Created by daniel on 16/7/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "RDVTabBarController.h"

@interface RootTabViewController : RDVTabBarController<RDVTabBarControllerDelegate>
-(instancetype)initWithLoginType:(LoginType)loginType;

@end
