#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface SystemValidator : NSObject
+ (void)showMenu;
@end

@implementation SystemValidator

static UIView *mainView;

+ (void)showMenu {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        mainView = [[UIView alloc] initWithFrame:window.bounds];
        mainView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [window addSubview:mainView];

        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, window.frame.size.width-100, 50)];
        field.placeholder = @"ENTER KEY HERE";
        field.backgroundColor = [UIColor whiteColor];
        field.textAlignment = NSTextAlignmentCenter;
        field.layer.cornerRadius = 8;
        [mainView addSubview:field];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(50, 220, window.frame.size.width-100, 50);
        btn.backgroundColor = [UIColor systemBlueColor];
        [btn setTitle:@"VERIFY & PLAY" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 8;
        [mainView addSubview:btn];

        objc_setAssociatedObject(btn, "k_field", field, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [btn addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    });
}

+ (void)check:(UIButton *)sender {
    UITextField *f = objc_getAssociatedObject(sender, "k_field");
    NSString *key = [f.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (key.length > 0) {
        [sender setTitle:@"CHECKING..." forState:UIControlStateNormal];
        
        // استخدام NSURLSession بالطرقة التقليدية بس مع إضافة "نخوة" للنظام
        NSString *urlStr = [NSString stringWithFormat:@"http://HostDooN.xo.je/check.php?key=%@&udid=828282828283", key];
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

        // طلب البيانات بدون استخدام الـ WebView المعلق
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
        [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)" forHTTPHeaderField:@"User-Agent"];

        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender setTitle:@"RETRY (NO INTERNET)" forState:UIControlStateNormal];
                });
                return;
            }

            if (data) {
                NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // تنظيف الرد من أي كود HTML ممكن تبعته الاستضافة المجانية
                if ([res containsString:@"YES"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [mainView removeFromSuperview];
                        mainView = nil;
                    });
                } else if ([res containsString:@"NO"]) {
                    exit(0);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [sender setTitle:@"INVALID KEY" forState:UIControlStateNormal];
                    });
                }
            }
        }] resume];
    }
}

@end

%ctor {
    [SystemValidator showMenu];
}
