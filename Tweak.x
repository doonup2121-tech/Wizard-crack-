#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// رابط سيرفرك في InfinityFree
#define SERVER_URL @"http://HostDooN.xo.je/check.php"

@interface DoonSecurity : NSObject
+ (void)launchSecurity;
@end

@implementation DoonSecurity

static NSTimer *timeoutTimer;
static UIView *mainOverlay; // لتخزين الواجهة وإزالتها عند النجاح

+ (void)launchSecurity {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // --- تعديل الاستقرار (1): التأكد من وجود نافذة نشطة والفحص المتكرر ---
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

        // إذا لم تكن اللعبة جاهزة (النافذة أو المتحكم غير موجود)، أعد المحاولة كل 0.5 ثانية
        if (!keyWindow || !keyWindow.rootViewController) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self launchSecurity];
            });
            return;
        }

        // منع تكرار ظهور الواجهة إذا كانت موجودة بالفعل
        if ([keyWindow viewWithTag:9999]) return;

        // --- البدء في رسم الواجهة لتطابق الصورة تماماً ---
        
        // 1. الخلفية المظلمة الشاملة (Overlay)
        mainOverlay = [[UIView alloc] initWithFrame:keyWindow.bounds];
        mainOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
        mainOverlay.tag = 9999;
        [keyWindow addSubview:mainOverlay];

        // 2. المربع الأبيض المركزي (Main Box) - تصميم مربع لمنع السكرول
        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 330)];
        box.center = keyWindow.center;
        box.backgroundColor = [UIColor whiteColor];
        box.layer.cornerRadius = 18;
        box.clipsToBounds = NO; // للسماح للأيقونة بالبروز للأعلى
        [mainOverlay addSubview:box];

        // 3. الأيقونة الزرقاء الدائرية (i) في الأعلى - مطابقة للصورة
        UIView *iconCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        iconCircle.backgroundColor = [UIColor colorWithRed:0.23 green:0.48 blue:0.85 alpha:1.0];
        iconCircle.layer.cornerRadius = 30;
        iconCircle.center = CGPointMake(155, 0); // وضعها في منتصف الحافة العلوية
        iconCircle.layer.borderWidth = 3;
        iconCircle.layer.borderColor = [UIColor whiteColor].CGColor;
        [box addSubview:iconCircle];

        UILabel *iconLabel = [[UILabel alloc] initWithFrame:iconCircle.bounds];
        iconLabel.text = @"i";
        iconLabel.textColor = [UIColor whiteColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.font = [UIFont boldSystemFontOfSize:35];
        [iconCircle addSubview:iconLabel];

        // 4. نصوص الترحيب (Welcome & Message)
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 310, 35)];
        titleLabel.text = @"Welcome";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:24];
        titleLabel.textColor = [UIColor blackColor];
        [box addSubview:titleLabel];

        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 270, 40)];
        msgLabel.text = @"Please enter your key";
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.font = [UIFont systemFontOfSize:15];
        msgLabel.textColor = [UIColor darkGrayColor];
        msgLabel.numberOfLines = 0;
        [box addSubview:msgLabel];

        // 5. خانة إدخال الكود (Key Field) - خلفية سوداء وتكبير الخط
        UITextField *keyField = [[UITextField alloc] initWithFrame:CGRectMake(25, 145, 260, 45)];
        keyField.backgroundColor = [UIColor blackColor];
        keyField.textColor = [UIColor whiteColor];
        keyField.placeholder = @"Key";
        keyField.secureTextEntry = YES;
        keyField.layer.cornerRadius = 8;
        keyField.textAlignment = NSTextAlignmentCenter;
        keyField.font = [UIFont boldSystemFontOfSize:17];
        keyField.keyboardAppearance = UIKeyboardAppearanceDark;
        
        // لون نص التلميح الرمادي
        NSDictionary *attr = @{NSForegroundColorAttributeName: [UIColor grayColor]};
        keyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Key" attributes:attr];
        [box addSubview:keyField];

        // 6. الأزرار الزرقاء العريضة (OK & Exit)
        UIColor *doonBlue = [UIColor colorWithRed:0.23 green:0.48 blue:0.85 alpha:1.0];

        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        okBtn.frame = CGRectMake(25, 205, 260, 48);
        okBtn.backgroundColor = doonBlue;
        [okBtn setTitle:@"OK" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        okBtn.layer.cornerRadius = 8;
        okBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [box addSubview:okBtn];

        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        exitBtn.frame = CGRectMake(25, 265, 260, 48);
        exitBtn.backgroundColor = doonBlue;
        [exitBtn setTitle:@"Exit" forState:UIControlStateNormal];
        [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        exitBtn.layer.cornerRadius = 8;
        exitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [box addSubview:exitBtn];

        // ربط الوظائف بالأزرار
        [exitBtn addTarget:self action:@selector(handleExit) forControlEvents:UIControlEventTouchUpInside];
        [okBtn addTarget:self action:@selector(onOkPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        // حفظ الحقل برمجياً للوصول إليه عند ضغط OK
        objc_setAssociatedObject(okBtn, "fieldRef", keyField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // بدء العد التنازلي للإغلاق في الخلفية (10 ثوانٍ)
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:NO block:^(NSTimer *timer) {
            exit(0); 
        }];
    });
}

+ (void)handleExit { exit(0); }

+ (void)onOkPressed:(UIButton *)sender {
    UITextField *field = objc_getAssociatedObject(sender, "fieldRef");
    [self verifyWithServer:field.text];
}

+ (void)verifyWithServer:(NSString *)userKey {
    // استخراج الـ UDID أوتوماتيكياً وربطه بالكود
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *fullRequest = [NSString stringWithFormat:@"%@?key=%@&udid=%@", SERVER_URL, userKey, deviceId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSString *serverResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:fullRequest] 
                                                        encoding:NSUTF8StringEncoding 
                                                           error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (serverResponse && [serverResponse containsString:@"YES"]) {
                [timeoutTimer invalidate]; // إيقاف المؤقت
                [mainOverlay removeFromSuperview]; // إغلاق الواجهة فوراً
                
                // استخراج تاريخ الانتهاء وعرض رسالة النجاح
                NSArray *data = [serverResponse componentsSeparatedByString:@"|"];
                NSString *expiry = (data.count > 1) ? data[1] : @"Unlimited";

                UIAlertController *welcome = [UIAlertController alertControllerWithTitle:@"Access Granted" 
                                             message:[NSString stringWithFormat:@"License expires on:\n%@", expiry] 
                                             preferredStyle:UIAlertControllerStyleAlert];
                [welcome addAction:[UIAlertAction actionWithTitle:@"Start" style:UIAlertActionStyleDefault handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:welcome animated:YES completion:nil];
            } else {
                exit(0); // غلق اللعبة عند الفشل
            }
        });
    });
}
@end

%ctor {
    // بدء الفحص بعد 3 ثوانٍ من تشغيل اللعبة لضمان استقرار البيئة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DoonSecurity launchSecurity];
    });
}
