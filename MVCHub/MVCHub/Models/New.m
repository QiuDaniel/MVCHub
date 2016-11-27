//
//  New.m
//  MVCHub
//
//  Created by daniel on 2016/10/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "New.h"

@implementation New

- (instancetype)initWithEvent:(OCTEvent *)event {
    self = [super init];
    if (self) {
        self.attributedString = [event mvc_attributedString];
        
        //create text container
        YYTextContainer *container = [[YYTextContainer alloc] init];
        container.size = CGSizeMake(kScreen_Width - 10 - 40 - 10 - 10, HUGE);
        container.maximumNumberOfRows = 0; //能显示的最大行数
        container.truncationType = YYTextTruncationTypeEnd;
        
        //generate a text layout
        self.textLayout = [YYTextLayout layoutWithContainer:container text:[event mvc_attributedString]];
        
        self.height = ({
            CGFloat height = 0;
            
            height += 10;
            height += self.textLayout.textBoundingSize.height;
            height += 10;
            
            height;
        });

    }
    return self;
}

@end
