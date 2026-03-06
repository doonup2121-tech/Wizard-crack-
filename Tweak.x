#import <UIKit/UIKit.h>

// رابط سيرفرك في InfinityFree
#define SERVER_URL @"http://HostDooN.xo.je/check.php"

@interface DoonSecurity : NSObject
+ (void)launchSecurity;
@end

@implementation DoonSecurity

static NSTimer *timeoutTimer;

+ (void)launchSecurity {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // --- تعديل الاستقرار (1): التأكد من وجود نافذة نشطة لمنع الكراش ---
        UIWindow *keyWindow = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    keyWindow = scene.windows.firstObject;
                    break;
                }
            }
        } else {
            keyWindow = [UIApplication sharedApplication].keyWindow;
        }

        // إذا لم تكن اللعبة جاهزة بعد، انتظر ثانية وحاول مجدداً بدلاً من الكراش
        if (!keyWindow || !keyWindow.rootViewController) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self launchSecurity];
            });
            return;
        }

        // إنشاء التنبيه بعنوان Welcome ورسالة ترحيب (تمت إزالة جملة الـ 10 ثوانٍ وتكبير المساحة بـ \n)
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Welcome" 
                                    message:@"Please enter your key\n\n\n" 
                                    preferredStyle:UIAlertControllerStyleAlert];

        // إضافة خانة إدخال المفتاح مع تعديل الألوان لتطابق الصورة (خلفية سوداء وتكبير الخط)
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Key";
            textField.secureTextEntry = YES;
            textField.textAlignment = NSTextAlignmentCenter;
            textField.backgroundColor = [UIColor blackColor]; // خلفية سوداء كما في الصورة
            textField.textColor = [UIColor whiteColor]; // نص أبيض
            textField.keyboardAppearance = UIKeyboardAppearanceDark;
            textField.font = [UIFont boldSystemFontOfSize:16]; // تكبير الخط لمنع السكرول
            
            // تخصيص لون نص التلميح (Placeholder) للرمادي
            NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Key" attributes:attributes];
        }];

        // زر التفعيل (OK) باللون الأزرق القياسي كما في الصورة
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [timeoutTimer invalidate]; // إيقاف مؤقت الـ 10 ثواني
            [self verifyWithServer:alert.textFields.firstObject.text];
        }];

        // زر الخروج (Exit) ليكون مطابقاً للتصميم باللون الأزرق
        UIAlertAction *exitBtn = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            exit(0); 
        }];

        [alert addAction:confirm];
        [alert addAction:exitBtn];
        
        // تعديل لون الأزرار العام للون الأزرق ليتطابق تماماً مع الصورة
        alert.view.tintColor = [UIColor systemBlueColor];

        // --- تعديل الاستقرار (2): عرض الواجهة بأمان فوق الـ RootViewController ---
        UIViewController *topController = keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:alert animated:YES completion:nil];

        // بدء العد التنازلي للإغلاق في الخلفية (وسيلة أمان: 10 ثوانٍ بدون نص)
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            exit(0); 
        }];
    });
}

+ (void)verifyWithServer:(NSString *)userKey {
    // استخراج الـ UDID أوتوماتيكياً وربطه بالكود المرسل للسيرفر
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *fullRequest = [NSString stringWithFormat:@"%@?key=%@&udid=%@", SERVER_URL, userKey, deviceId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSString *serverResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:fullRequest] 
                                                        encoding:NSUTF8StringEncoding 
                                                           error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // عرض تفاصيل الاشتراك فور التفعيل (تاريخ ووقت ودقيقة)
            if (serverResponse && [serverResponse containsString:@"YES"]) {
                NSArray *data = [serverResponse componentsSeparatedByString:@"|"];
                NSString *expiry = (data.count > 1) ? data[1] : @"Unlimited";

                UIAlertController *welcome = [UIAlertController alertControllerWithTitle:@"Access Granted" 
                                             message:[NSString stringWithFormat:@"License expires on:\n%@", expiry] 
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                [welcome addAction:[UIAlertAction actionWithTitle:@"Start" style:UIAlertActionStyleDefault handler:nil]];
                
                // العرض فوق الواجهة الحالية
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                [keyWindow.rootViewController presentViewController:welcome animated:YES completion:nil];
            } else {
                // فشل التفعيل أو عدم تطابق UDID: إغلاق فوري لزيادة الأمان
                exit(0);
            }
        });
    });
}
@end

%ctor {
    // --- تعديل الاستقرار (3): تقليل وقت الانتظار إلى 3 ثوانٍ كما طلبت لضمان استقرار اللعبة ---
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DoonSecurity launchSecurity];
    });
}
