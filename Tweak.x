#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@interface GhostValidator : NSObject <WKNavigationDelegate>
+ (void)launch;
@end

@implementation GhostValidator

static UIView *overlayView;
static WKWebView *hiddenWebView;
static UIButton *actionBtn;

+ (void)launch {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;
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

        actionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        actionBtn.frame = CGRectMake(50, window.center.y - 30, window.frame.size.width - 100, 50);
        [actionBtn setTitle:@"ACTIVATE" forState:UIControlStateNormal];
        [actionBtn setBackgroundColor:[UIColor systemGreenColor]];
        [actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        actionBtn.layer.cornerRadius = 10;
        [overlayView addSubview:actionBtn];

        // إعداد المتصفح مع User-Agent حقيقي لتخطي حماية الاستضافة
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        hiddenWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        hiddenWebView.customUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1";
        hiddenWebView.navigationDelegate = (id<WKNavigationDelegate>)self;
        [overlayView addSubview:hiddenWebView];

        objc_setAssociatedObject(actionBtn, "input_field", keyInput, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [actionBtn addTarget:self action:@selector(fireCheck:) forControlEvents:UIControlEventTouchUpInside];
    });
}

+ (void)fireCheck:(UIButton *)sender {
    UITextField *field = objc_getAssociatedObject(sender, "input_field");
    NSString *key = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (key.length > 0) {
        [sender setTitle:@"CONNECTING..." forState:UIControlStateNormal];
        sender.enabled = NO;

        NSString *urlStr = [NSString stringWithFormat:@"http://HostDooN.xo.je/check.php?key=%@&udid=828282828283", key];
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        
        [hiddenWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

// دالة التعامل مع الأخطاء (لو السيرفر واقع مثلاً)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [actionBtn setTitle:@"RETRY (Network Error)" forState:UIControlStateNormal];
        actionBtn.enabled = YES;
    });
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // الانتظار ثانية واحدة للتأكد من أن الاستضافة المجانية حملت المحتوى
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [webView evaluateJavaScript:@"document.body.innerText" completionHandler:^(id result, NSError *error) {
            NSString *response = (NSString *)result;
            
            if (response && [response isKindOfClass:[NSString class]]) {
                if ([response containsString:@"YES"]) {
                    [overlayView removeFromSuperview];
                    overlayView = nil;
                } else if ([response containsString:@"NO"]) {
                    exit(0);
                } else {
                    // إذا لم يجد YES أو NO، يظهر ما الذي وجده المتصفح (للتصحيح)
                    [actionBtn setTitle:@"INVALID RESPONSE" forState:UIControlStateNormal];
                    actionBtn.enabled = YES;
                    NSLog(@"Server Output: %@", response);
                }
            }
        }];
    });
}

@end

%ctor {
    [GhostValidator launch];
}
