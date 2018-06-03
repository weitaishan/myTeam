//
//  SHWebviewProgressLine.h
//  SHWebView
//
//  Created by tanchuanjiang on 2018/6/3.
//  Copyright © 2018年 tanchuanjiang. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface SHWebviewProgressLine : UIView

//进度条颜色
@property (nonatomic, strong) UIColor *lineColor;

//开始加载
- (void)startLoadingAnimation;

//结束加载
- (void)endLoadingAnimation;

@end
