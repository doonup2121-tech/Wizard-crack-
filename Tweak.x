#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h> // السطر المطلوب لحل خطأ الصورة الثانية

// رابط سيرفرك في InfinityFree
#define SERVER_URL @"http://HostDooN.xo.je/check.php"

// إضافة بروتوكول UITextFieldDelegate لدعم زر Enter
@interface DoonSecurity : NSObject <UITextFieldDelegate>
+ (void)launchSecurity;
@end

@implementation DoonSecurity

static NSTimer *timeoutTimer;
static UIView *mainOverlay; // لتخزين الواجهة وإزالتها عند النجاح

// --- وظيفة حماية المكتبة: إذا تم مسح الملف اللعبة تكراش ---
+ (void)checkLibraryIntegrity {
    // التعديل الآمن: بنسأل النظام هل مكتبة "DoonN_Wizard" محملة حالياً في الذاكرة؟
    // تم تغيير الاسم هنا ليطابق اسم التويك الظاهر في الصورة (DoonN_Wizard)
    BOOL isLoaded = NO;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count ; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name != NULL && strstr(name, "DoonN_Wizard.dylib")) {
            isLoaded = YES;
            break;
        }
    }
    
    if (!isLoaded) {
        exit(0); 
    }
}

+ (void)launchSecurity {
    // استدعاء فحص وجود المكتبة قبل إظهار الواجهة
    [self checkLibraryIntegrity];

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

        // إذا لم تكن اللعبة جاهزة، أعد المحاولة كل 0.5 ثانية
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

        // 2. المربع الأبيض المركزي (Main Box)
        // تم تعديل الـ Center Y لرفع الواجهة للأعلى (Y - 80) لكي لا يغطيها الكيبورد
        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 330)];
        box.center = CGPointMake(keyWindow.center.x, keyWindow.center.y - 80);
        box.backgroundColor = [UIColor whiteColor];
        box.layer.cornerRadius = 18;
        box.clipsToBounds = NO; 
        [mainOverlay addSubview:box];

        // 3. الأيقونة الزرقاء الدائرية (i) في الأعلى
        UIView *iconCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        iconCircle.backgroundColor = [UIColor colorWithRed:0.23 green:0.48 blue:0.85 alpha:1.0];
        iconCircle.layer.cornerRadius = 30;
        iconCircle.center = CGPointMake(155, 0); 
        iconCircle.layer.borderWidth = 3;
        iconCircle.layer.borderColor = [UIColor whiteColor].CGColor;
        [box addSubview:iconCircle];

        UILabel *iconLabel = [[UILabel alloc] initWithFrame:iconCircle.bounds];
        iconLabel.text = @"i";
        iconLabel.textColor = [UIColor whiteColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.font = [UIFont boldSystemFontOfSize:35];
        [iconCircle addSubview:iconLabel];

        // 4. نصوص الترحيب
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

        // 5. خانة إدخال الكود (Key Field)
        UITextField *keyField = [[UITextField alloc] initWithFrame:CGRectMake(25, 145, 260, 45)];
        keyField.backgroundColor = [UIColor blackColor];
        keyField.textColor = [UIColor whiteColor];
        keyField.placeholder = @"Key";
        keyField.secureTextEntry = NO; 
        keyField.layer.cornerRadius = 8;
        keyField.textAlignment = NSTextAlignmentCenter;
        keyField.font = [UIFont boldSystemFontOfSize:17];
        keyField.keyboardAppearance = UIKeyboardAppearanceDark;
        keyField.returnKeyType = UIReturnKeyDone; 
        keyField.delegate = (id<UITextFieldDelegate>)self; 
        
        // تم تعطيل الفحص اللحظي لمنع كراش اللصق
        // [keyField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
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

        [exitBtn addTarget:self action:@selector(handleExit) forControlEvents:UIControlEventTouchUpInside];
        [okBtn addTarget:self action:@selector(onOkPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        objc_setAssociatedObject(okBtn, "fieldRef", keyField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // زيادة وقت المؤقت لـ 60 ثانية
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 repeats:NO block:^(NSTimer *timer) {
            exit(0); 
        }];
    });
}

// وظيفة الفحص التلقائي (معطلة حالياً لمنع كراش اللصق)
+ (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length >= 20) {
        [self verifyWithServer:textField.text];
    }
}

// وظيفة دعم زر Enter/Done من الكيبورد
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [DoonSecurity verifyWithServer:textField.text];
    return YES;
}

+ (void)handleExit { exit(0); }

+ (void)onOkPressed:(UIButton *)sender {
    UITextField *field = objc_getAssociatedObject(sender, "fieldRef");
    if (field.text.length > 0) {
        [self verifyWithServer:field.text];
    }
}

+ (void)verifyWithServer:(NSString *)userKey {
    // حل منع الكراش عند OK: تنفيذ العملية في خيط خلفي (Background Thread)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *cleanKey = [userKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        NSString *urlRaw = [NSString stringWithFormat:@"%@?key=%@&udid=%@", SERVER_URL, cleanKey, deviceId];
        NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *requestURL = [NSURL URLWithString:urlEncoded];

        [[[NSURLSession sharedSession] dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error || !data) {
                    exit(0); 
                    return;
                }

                NSString *serverResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *cleanResponse = [serverResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                if (cleanResponse && [cleanResponse rangeOfString:@"YES" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [timeoutTimer invalidate]; 
                    [mainOverlay removeFromSuperview]; 
                    
                    NSArray *dataParts = [cleanResponse componentsSeparatedByString:@"|"];
                    NSString *expiry = (dataParts.count > 1) ? dataParts[1] : @"Unlimited";

                    UIAlertController *welcome = [UIAlertController alertControllerWithTitle:@"Access Granted" 
                                                 message:[NSString stringWithFormat:@"License expires on:\n%@", expiry] 
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    [welcome addAction:[UIAlertAction actionWithTitle:@"Start" style:UIAlertActionStyleDefault handler:nil]];
                    
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    [window.rootViewController presentViewController:welcome animated:YES completion:nil];
                } else {
                    exit(0); 
                }
            });
        }] resume];
    });
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DoonSecurity launchSecurity];
    });
}
