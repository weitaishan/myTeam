//
//  SHWebViewController.h
//  SHWebView
//
//  Created by tanchuanjiang on 2018/6/3.
//  Copyright © 2018年 tanchuanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHWebViewController : UIViewController

/** 加载的url */
@property (nonatomic, copy) NSString *loadUrl;
/** 首页的url */
@property (nonatomic, copy) NSString *rootUrl;
/** 进度条颜色 */
@property (nonatomic, strong) UIColor *lineColor;
/** 是否显示工具栏 */
@property (nonatomic, assign) BOOL isShowTool;

@end
