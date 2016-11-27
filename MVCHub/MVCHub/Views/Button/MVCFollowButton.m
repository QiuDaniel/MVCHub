//
//  MVCFollowButton.m
//  MVCHub
//
//  Created by daniel on 2016/10/19.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "MVCFollowButton.h"

#define MVC_FOLLOW_BUTTON_IMAGE_SIZE CGSizeMake(16, 16)

static UIImage *_image = nil;
static UIImage *_selectedImage = nil;

@implementation MVCFollowButton

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _image = [UIImage imageNamed:@"UMS_like_off_white"];
        _selectedImage = [UIImage imageNamed:@"UMS_like_on_white"];
    });
    self.layer.borderColor = [UIColor colorWithHexString:@"0xd5d5d5"].CGColor;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.contentEdgeInsets = UIEdgeInsetsMake(7, 1, 7, 3);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (!selected) {
        [self setImage:_image forState:UIControlStateNormal];
        [self setTitle:@"Follow" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHexString:@"0xffffff"] forState:UIControlStateNormal];
        
        self.backgroundColor = [UIColor colorWithHexString:@"0x569e3d"];
        self.layer.borderWidth = 0;
    } else {
        [self setImage:_selectedImage forState:UIControlStateNormal];
        [self setTitle:@"UnFollow" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHexString:@"0x333333"] forState:UIControlStateNormal];
        
        self.backgroundColor = [UIColor colorWithHexString:@"0xeeeeee"];
        self.layer.borderWidth = 1;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
