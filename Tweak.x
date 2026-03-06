#import <UIKit/UIKit.h>

@interface StealthTest : NSObject
@end

@implementation StealthTest

static UIView *miniView;

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;

        miniView = [[UIView alloc] initWithFrame:win.bounds];
        miniView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [win addSubview:miniView];

        UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        checkBtn.frame = CGRectMake(0, 0, 200, 50);
        checkBtn.center = win.center;
        checkBtn.backgroundColor = [UIColor redColor];
        [checkBtn setTitle:@"TAP TO TEST" forState:UIControlStateNormal];
        [miniView addSubview:checkBtn];

        [checkBtn addTarget:self action:@selector(doCheck) forControlEvents:UIControlEventTouchUpInside];
    });
}

+ (void)doCheck {
    // طريقة "قديمة جداً" لجلب البيانات لمنع اكتشاف NSURLSession
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // رابط تجريبي مباشر (تأكد أن السيرفر يطبع YES فقط)
        NSString *urlStr = @"http://HostDooN.xo.je/check.php?key=TEST";
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSError *error = nil;
        // استخدام NSData لجلب المحتوى بشكل صامت (Low Level)
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        
        if (data) {
            NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([res containsString:@"YES"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [miniView removeFromSuperview];
                });
            } else {
                exit(0);
            }
        } else {
            // لو فشل الاتصال خالص (اللعبة منعت البيانات)
            dispatch_async(dispatch_get_main_queue(), ^{
                [miniView setBackgroundColor:[UIColor yellowColor]]; // تنبيه بالفشل
            });
        }
    });
}
@end
