#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface SystemValidator : NSObject
+ (void)showMenu;
@end

@implementation SystemValidator

static UIView *mainView;

+ (void)showMenu {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) { window = scene.windows.firstObject; break; }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        if ([window viewWithTag:9911]) return;

        mainView = [[UIView alloc] initWithFrame:window.bounds];
        mainView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        mainView.tag = 9911;
        [window addSubview:mainView];

        // --- تعديل مكان الصندوق ليصبح في الأعلى قليلاً ---
        // بدلاً من المنتصف (window.center)، سنرفعه بمقدار 100 نقطة للأعلى
        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
        box.center = CGPointMake(window.center.x, window.center.y - 120); 
        box.backgroundColor = [UIColor whiteColor];
        box.layer.cornerRadius = 15;
        [mainView addSubview:box];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 30)];
        title.text = @"VIP ACCESS";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:20];
        [box addSubview:title];

        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(25, 70, 250, 45)];
        field.placeholder = @"Paste Key Here";
        field.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        field.textAlignment = NSTextAlignmentCenter;
        field.layer.cornerRadius = 8;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
        [box addSubview:field];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(25, 140, 250, 50);
        btn.backgroundColor = [UIColor systemBlueColor];
        [btn setTitle:@"ACTIVATE NOW" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 8;
        [box addSubview:btn];

        objc_setAssociatedObject(btn, "k_field", field, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [btn addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    });
}

+ (void)check:(UIButton *)sender {
    UITextField *f = objc_getAssociatedObject(sender, "k_field");
    [f resignFirstResponder]; // إخفاء الكيبورد عند الضغط

    NSString *key = [f.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (key.length > 0) {
        [sender setTitle:@"VERIFYING..." forState:UIControlStateNormal];
        sender.enabled = NO;
        
        NSString *realUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *urlStr = [NSString stringWithFormat:@"http://HostDooN.xo.je/check.php?key=%@&udid=%@", key, realUUID];
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
        // تمويه إضافي لتخطي صفحة الـ HTML اللي بتظهر في الصورة
        [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" forHTTPHeaderField:@"User-Agent"];

        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    // فحص ذكي للرد حتى لو السيرفر بعت HTML
                    if ([res containsString:@"YES|"]) {
                        [mainView removeFromSuperview];
                        mainView = nil;
                    } 
                    else if ([res containsString:@"INVALID_KEY"]) { [sender setTitle:@"INVALID KEY" forState:UIControlStateNormal]; sender.enabled = YES; }
                    else if ([res containsString:@"WRONG_DEVICE"]) { [sender setTitle:@"WRONG DEVICE" forState:UIControlStateNormal]; sender.enabled = YES; }
                    else if ([res containsString:@"EXPIRED"]) { [sender setTitle:@"KEY EXPIRED" forState:UIControlStateNormal]; sender.enabled = YES; }
                    else {
                        // لو لسه بيظهر لك الـ HTML اللي في الصورة، الكود ده هيحاول يطنشها ويجرب تاني
                        [sender setTitle:@"RETRY (SERVER BUSY)" forState:UIControlStateNormal];
                        sender.enabled = YES;
                    }
                } else {
                    [sender setTitle:@"NO INTERNET" forState:UIControlStateNormal];
                    sender.enabled = YES;
                }
            });
        }] resume];
    }
}
@end

%ctor { [SystemValidator showMenu]; }
