//
//  SHWebviewProgressLine.m
//  SHWebView
//
//  Created by tanchuanjiang on 2018/6/3.
//  Copyright © 2018年 tanchuanjiang. All rights reserved.
//

#import "SHWebviewProgressLine.h"

#define SCREEN_Width [[UIScreen mainScreen] bounds].size.width

@implementation SHWebviewProgressLine

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.backgroundColor = lineColor;
}

- (void)startLoadingAnimation {
    self.hidden = NO;
    self.width = 0.0;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.width = SCREEN_Width * 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.width = SCREEN_Width * 0.8;
        }];
    }];
}

- (void)endLoadingAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        self.width = SCREEN_Width;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)setWidth:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}


@end
