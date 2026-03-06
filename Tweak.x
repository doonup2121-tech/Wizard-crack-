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
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        mainView = [[UIView alloc] initWithFrame:window.bounds];
        mainView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        [window addSubview:mainView];

        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
        box.center = window.center;
        box.backgroundColor = [UIColor whiteColor];
        box.layer.cornerRadius = 15;
        [mainView addSubview:box];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 30)];
        title.text = @"VIP LOGIN";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:20];
        [box addSubview:title];

        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(25, 70, 250, 45)];
        field.placeholder = @"Enter License Key";
        field.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        field.textAlignment = NSTextAlignmentCenter;
        field.layer.cornerRadius = 8;
        [box addSubview:field];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(25, 140, 250, 50);
        btn.backgroundColor = [UIColor systemBlueColor];
        [btn setTitle:@"ACTIVATE" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 8;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [box addSubview:btn];

        objc_setAssociatedObject(btn, "k_field", field, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [btn addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    });
}

+ (void)check:(UIButton *)sender {
    UITextField *f = objc_getAssociatedObject(sender, "k_field");
    NSString *key = [f.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (key.length > 0) {
        [sender setTitle:@"CONNECTING..." forState:UIControlStateNormal];
        sender.enabled = NO;
        
        NSString *realUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *urlStr = [NSString stringWithFormat:@"http://HostDooN.xo.je/check.php?key=%@&udid=%@", key, realUUID];
        NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
        [request setValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];

        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [sender setTitle:@"NETWORK ERROR" forState:UIControlStateNormal];
                    sender.enabled = YES;
                    return;
                }

                NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                if ([res containsString:@"YES|"]) {
                    // استخراج تاريخ الانتهاء من الرد (مثلاً: YES|2026-03-10)
                    NSArray *parts = [res componentsSeparatedByString:@"|"];
                    NSString *expiryDate = (parts.count > 1) ? parts[1] : @"Unknown";
                    
                    [sender setTitle:@"SUCCESS!" forState:UIControlStateNormal];
                    
                    // تنبيه المستخدم بتاريخ الانتهاء قبل الدخول
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Activated!" message:[NSString stringWithFormat:@"Expiry: %@", expiryDate] preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [mainView removeFromSuperview];
                        mainView = nil;
                    }]];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                    
                } else {
                    [sender setTitle:res forState:UIControlStateNormal]; // هيعرض INVALID_KEY أو WRONG_DEVICE
                    sender.enabled = YES;
                }
            });
        }] resume];
    }
}

@end

%ctor {
    [SystemValidator showMenu];
}
