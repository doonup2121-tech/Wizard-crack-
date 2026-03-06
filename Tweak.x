#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface GhostValidator : NSObject <WKNavigationDelegate>
+ (void)launch;
@end

@implementation GhostValidator

static UIView *overlayView;
static WKWebView *hiddenWebView;

+ (void)launch {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        overlayView = [[UIView alloc] initWithFrame:window.bounds];
        overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        [window addSubview:overlayView];

        UITextField *keyInput = [[UITextField alloc] initWithFrame:CGRectMake(50, window.center.y - 100, window.frame.size.width - 100, 50)];
        keyInput.placeholder = @"ENTER KEY";
        keyInput.backgroundColor = [UIColor whiteColor];
        keyInput.textAlignment = NSTextAlignmentCenter;
        keyInput.layer.cornerRadius = 10;
        [overlayView addSubview:keyInput];

        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        goBtn.frame = CGRectMake(50, window.center.y - 30, window.frame.size.width - 100, 50);
        [goBtn setTitle:@"ACTIVATE" forState:UIControlStateNormal];
        [goBtn setBackgroundColor:[UIColor systemGreenColor]];
        [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        goBtn.layer.cornerRadius = 10;
        [overlayView addSubview:goBtn];

        // إنشاء متصفح مخفي تماماً
        hiddenWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        hiddenWebView.navigationDelegate = (id<WKNavigationDelegate>)self;
        [overlayView addSubview:hiddenWebView];

        objc_setAssociatedObject(goBtn, "input_field", keyInput, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [goBtn addTarget:self action:@selector(fireCheck:) forControlEvents:UIControlEventTouchUpInside];
    });
}

+ (void)fireCheck:(UIButton *)sender {
    UITextField *field = objc_getAssociatedObject(sender, "input_field");
    NSString *key = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (key.length > 0) {
        // بناء الرابط
        NSString *urlStr = [NSString stringWithFormat:@"%@?key=%@&udid=828282828283", @"http://HostDooN.xo.je/check.php", key];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        
        // التحميل داخل المتصفح المخفي (الحماية لا تراقب المتصفح عادة)
        [hiddenWebView loadRequest:request];
    }
}

// مراقبة رد السيرفر من داخل المتصفح
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.body.innerText" completionHandler:^(id result, NSError *error) {
        NSString *response = (NSString *)result;
        if ([response containsString:@"YES"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [overlayView removeFromSuperview];
                overlayView = nil;
            });
        } else if ([response containsString:@"NO"]) {
            exit(0);
        }
    }];
}

@end

%ctor {
    [GhostValidator launch];
}
