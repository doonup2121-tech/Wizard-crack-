#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define S_URL @"http://HostDooN.xo.je/check.php"

@interface TestSecurity : NSObject
+ (void)showBox;
@end

@implementation TestSecurity

static UIView *overlay;

+ (void)showBox {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;

        overlay = [[UIView alloc] initWithFrame:win.bounds];
        overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [win addSubview:overlay];

        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
        box.center = win.center;
        box.backgroundColor = [UIColor whiteColor];
        box.layer.cornerRadius = 10;
        [overlay addSubview:box];

        UITextField *input = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 240, 40)];
        input.placeholder = @"Enter Key";
        input.borderStyle = UITextBorderStyleRoundedRect;
        input.textAlignment = NSTextAlignmentCenter;
        [box addSubview:input];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 100, 240, 50);
        [btn setTitle:@"VERIFY" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor systemBlueColor]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        [box addSubview:btn];

        // ربط الحقول بالزر
        objc_setAssociatedObject(btn, "input_key", input, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [btn addTarget:self action:@selector(checkKey:) forControlEvents:UIControlEventTouchUpInside];
    });
}

+ (void)checkKey:(UIButton *)sender {
    UITextField *field = objc_getAssociatedObject(sender, "input_key");
    NSString *key = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (key.length == 0) return;

    // طلب بسيط جداً (Simple GET)
    NSString *fullUrl = [NSString stringWithFormat:@"%@?key=%@", S_URL, key];
    NSURL *url = [NSURL URLWithString:[fullUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([res containsString:@"YES"]) {
                // نجاح -> إخفاء الواجهة
                dispatch_async(dispatch_get_main_queue(), ^{
                    [overlay removeFromSuperview];
                    overlay = nil;
                });
            } else {
                // فشل -> إغلاق اللعبة
                exit(0);
            }
        }
    }] resume];
}

@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TestSecurity showBox];
    });
}
