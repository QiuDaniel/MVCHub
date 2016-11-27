//
//  Input_OnlyText_Cell.h
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#define kCellIdentifier_Input_OnlyText_Cell_Text @"Input_OnlyText_Cell_Text"
#define kCellIdentifier_Input_OnlyText_Cell_Password @"Input_OnlyText_Cell_Password"
#define kCellIdentifier_Input_OnlyText_Cell_Phone @"Input_OnlyText_Cell_Phone"

#import <UIKit/UIKit.h>

@interface Input_OnlyText_Cell : UITableViewCell
@property (nonatomic, strong, readonly) UITextField *textFiled;
@property (nonatomic, assign) BOOL isForLoginVC;
@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, copy) void(^textValueChangedBlock)(NSString *);
@property (nonatomic, copy) void(^editDidBeginBlock)(NSString *);
@property (nonatomic, copy) void(^editDidEndBlock)(NSString *);

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr;
@end
