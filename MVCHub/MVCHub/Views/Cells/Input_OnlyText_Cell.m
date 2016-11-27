//
//  Input_OnlyText_Cell.m
//  MVCHub
//
//  Created by daniel on 2016/10/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "Input_OnlyText_Cell.h"

@interface Input_OnlyText_Cell ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *clearBtn, *passwordBtn;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation Input_OnlyText_Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_textFiled) {
            _textFiled = [[UITextField alloc] init];
            [_textFiled setFont:[UIFont systemFontOfSize:17]];
            _textFiled.textColor = [UIColor blackColor];
            self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
            _textFiled.leftViewMode = UITextFieldViewModeAlways;
            _textFiled.leftView = self.iconImageView;
            [_textFiled addTarget:self action:@selector(editDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [_textFiled addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [_textFiled addTarget:self action:@selector(editDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            [self.contentView addSubview:_textFiled];
            [_textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Text]) {
            
        }else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]){
            if (!_passwordBtn) {
                _textFiled.secureTextEntry = YES;
                _passwordBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 44 -kLoginPaddingLeftWidth, 0, 44, 44)];
                [_passwordBtn addTarget:self action:@selector(passwordBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_passwordBtn setImage:[UIImage imageNamed:@"password_unlook"] forState:UIControlStateNormal];
            }
        }
    }
    return self;
}

- (void)prepareForReuse {
    self.isForLoginVC = NO;
    if (![self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]) {
        self.textFiled.secureTextEntry = NO;
    }
    self.textFiled.userInteractionEnabled = YES;
    self.textFiled.keyboardType = UIKeyboardTypeDefault;
    
    self.editDidBeginBlock = nil;
    self.textValueChangedBlock = nil;
    self.editDidEndBlock = nil;
}

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr {
//    self.textFiled.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phStr ? phStr: @"" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:_isForLoginVC? @"0xffffff": @"0x999999" andAlpha:_isForLoginVC? 0.5: 1.0]}];
    self.textFiled.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phStr ? phStr: @"" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0]}];
    self.textFiled.text = valueStr;
}

#pragma mark - UIView
- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isForLoginVC) {
        if (!_clearBtn) {
            _clearBtn = [UIButton new];
            _clearBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [_clearBtn setImage:[UIImage imageNamed:@"text_clear_btn"] forState:UIControlStateNormal];
            [_clearBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_clearBtn];
            [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if (!_lineView) {
            _lineView = [UIView new];
            //_lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
            _lineView.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
            [self.contentView addSubview:_lineView];
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.5);
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.bottom.equalTo(self.contentView);
            }];
        }
        
    }
    self.backgroundColor = _isForLoginVC? [UIColor clearColor]: [UIColor whiteColor];
//    self.textFiled.clearButtonMode = _isForLoginVC? UITextFieldViewModeNever: UITextFieldViewModeWhileEditing;
    self.textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textFiled.textColor = _isForLoginVC? [UIColor blackColor]: [UIColor colorWithHexString:@"0x222222"];
    self.lineView.hidden = !_isForLoginVC;
    self.clearBtn.hidden = YES;
    
    UIView *rightElement;
    if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Text]) {
        rightElement = nil;
    } else if([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]){
        rightElement = _passwordBtn;
    }
    
    [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - kScreen_Width - 10): -kLoginPaddingLeftWidth;
        make.right.equalTo(self.contentView).offset(offset);
    }];
    
    [_textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - kScreen_Width - 10): -kLoginPaddingLeftWidth;
        offset -= self.isForLoginVC? 30: 0;
        make.right.equalTo(self.contentView).offset(offset);
    }];
}
#pragma mark - textfield
- (void)editDidBegin:(id)sender {
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff"];
    self.clearBtn.hidden = _isForLoginVC? self.textFiled.text.length <=0: YES;
    
    if (self.editDidBeginBlock) {
        self.editDidBeginBlock(self.textFiled.text);
    }
}

- (void)textValueChanged:(id)sender {
    self.clearBtn.hidden = _isForLoginVC? self.textFiled.text.length <=0: YES;
    
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textFiled.text);
    }
}

- (void)editDidEnd:(id)sender {
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
    self.clearBtn.hidden = YES;
    if (self.editDidEndBlock) {
        self.editDidEndBlock(self.textFiled.text);
    }
}
#pragma mark - Button
- (void)clearBtnClicked:(id)sender {
    self.textFiled.text = @"";
    [self textValueChanged:nil];
}
#pragma mark - password
- (void)passwordBtnClicked:(id)sender {
    _textFiled.secureTextEntry = !_textFiled.secureTextEntry;
    UIButton *button = (UIButton *)sender;
    [button setImage:[UIImage imageNamed:_textFiled.secureTextEntry? @"password_unlook": @"password_look"] forState:UIControlStateNormal];
}
@end
