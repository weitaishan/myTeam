//
//  SHWebViewController.m
//  SHWebView
//
//  Created by tanchuanjiang on 2018/6/3.
//  Copyright © 2018年 tanchuanjiang. All rights reserved.
//

#import "SHWebViewController.h"
#import "SHWebviewProgressLine.h"

#define SCREEN_Width [[UIScreen mainScreen] bounds].size.width
#define SCREEN_Height [[UIScreen mainScreen] bounds].size.height

typedef NS_ENUM(NSUInteger, SHGestureState) {
    SHGestureStateNone,
    SHGestureStateStart,
    SHGestureStateMove,
    SHGestureStateEnd,
};

@interface SHWebViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) SHWebviewProgressLine *progressLine;

@property (nonatomic, copy) NSString *saveImageUrl;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) SHGestureState state;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, copy) NSString *currentURL;

@end

@implementation SHWebViewController

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
    }
    return _footerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.footerView];

    self.progressLine = [[SHWebviewProgressLine alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 1.5)];
    self.progressLine.lineColor = self.lineColor;
    [self.view addSubview:self.progressLine];
    
    NSURL *url = [NSURL URLWithString:self.loadUrl];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.delegate = self;
    [self.webView addGestureRecognizer:longPressed];
    if (self.isShowTool) {
        [self showFooterView];
        [self loadFooterView];
    }
    else {
        [self hiddenFooterView];
    }
}

- (void)loadFooterView {
    NSArray *titles = @[@"首页", @"后退", @"前进", @"刷新", @"缓存"];
    CGFloat width = SCREEN_Width / 5;
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(width * i, 0, width, 49);
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:titles[i] forState:0];
        [btn setTitleColor:[UIColor redColor] forState:0];
        [self.footerView addSubview:btn];
    }
}

#pragma mark -- tool
//首页
- (void)webViewLoadRootUrl {
    NSURL *url = [NSURL URLWithString:self.rootUrl];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}
//后退
- (void)goBackWebView {
    [self.webView goBack];
}
//前进
- (void)goForwardWebView {
    [self.webView goForward];
}
//刷新
- (void)refreshWebView {
    [self.webView reload];
}
//缓存
- (void)webViewLoadCacheData {
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)
//                            objectAtIndex:0];
//    NSString *path = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/Caches/%@.html", self.currentURL]];
//
//    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    if (!(htmlString == nil || [htmlString isEqualToString:@""])) {
//        [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:self.currentURL]];
//    }
//    else {
//        NSURL *url = [NSURL URLWithString:self.currentURL];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//        [self.webView loadRequest:request];
//        [self writeToCache];
//    }
    [self writeToCache];
}

/** 网页缓存写入文件 */
- (void)writeToCache {
    NSString *htmlResponseStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.currentURL]
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    //创建文件管理器
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    //获取document路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
                            objectAtIndex:0];
    
    [fileManager createDirectoryAtPath:[cachesPath stringByAppendingString:@"/Caches"] withIntermediateDirectories:YES attributes:nil error:nil];
    //写入路径
    NSString * path = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/Caches/%@.html", self.currentURL]];
    [htmlResponseStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}



//隐藏footerView
- (void)hiddenFooterView {
    [UIView animateWithDuration:0.25 animations:^{
        self.footerView.frame = CGRectMake(0, SCREEN_Height, SCREEN_Width, 49);
        self.webView.frame = CGRectMake(0, 0, SCREEN_Width, SCREEN_Height);
    }];
}
//显示footerView
- (void)showFooterView {
    [UIView animateWithDuration:0.25 animations:^{
        self.footerView.frame = CGRectMake(0, SCREEN_Height - 49, SCREEN_Width, 49);
        self.webView.frame = CGRectMake(0, 0, SCREEN_Width, SCREEN_Height - 49);
    }];
}

- (void)webViewToolCanGoBackAndGoForward {
    if (self.webView.canGoBack) {
        
    }
    if (self.webView.canGoForward) {
        
    }
}

#pragma mark -- UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.progressLine startLoadingAnimation];
    [self webViewToolCanGoBackAndGoForward];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.progressLine endLoadingAnimation];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    [self.progressLine endLoadingAnimation];
    [self webViewToolCanGoBackAndGoForward];
}

#pragma mark -- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:self.webView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    if (urlToSave.length == 0) {
        return;
    }
    
    UIAlertController *alertVC =  [UIAlertController alertControllerWithTitle:nil message:@"确定保存图片到相册吗？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveImageToDiskWithUrl:urlToSave];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - private method
- (void)saveImageToDiskWithUrl:(NSString *)imageUrl{
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        NSData *imageData = [NSData dataWithContentsOfURL:location];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
        });
    }];
    [task resume];
}

#pragma mark 保存图片后的回调
- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:  (NSError*)error contextInfo:(id)contextInfo{
    if(!error) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:@"成功保存到相册" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
        [alertControl addAction:action];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
    else {
        NSLog(@"%@", [error description]);
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片保存失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertControl addAction:action];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}
                                                      
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
