#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// دوال ثابتة لإرجاع "نعم" أو "تم التحقق" لكسر أي فحص
static BOOL returnTrue() { return YES; }
static id returnValidated() { return @"Validated"; }

%ctor {
    NSLog(@"[DooN UP] Starting Ultimate Bypass...");

    // 1. كسر حماية كلاسات الـ Wizard (بناءً على ملف Wizard اللي بعته)
    // ده بيخلي السيرفر يفتكر إن جهازك مسموح له بالدخول
    Class wizAuth = objc_getClass("WizardFrameworkAuth");
    if (wizAuth) {
        class_replaceMethod(wizAuth, @selector(isDeviceAuthorized), (IMP)returnTrue, "B@:");
        class_replaceMethod(wizAuth, @selector(checkSubscription), (IMP)returnTrue, "B@:");
    }
    
    // 2. تخطي فحص المفتاح (Key) في المكتبة الرئيسية
    Class mainAuth = objc_getClass("WizardAuth");
    if (mainAuth) {
        class_replaceMethod(mainAuth, @selector(checkKey:), (IMP)returnTrue, "B@:@");
        class_replaceMethod(mainAuth, @selector(getValidationStatus), (IMP)returnValidated, "@@:");
    }

    // 3. التعامل مع ملف الـ .dat والقيم المحفوظة (الهيكس)
    // هنا بنجبر البرنامج يقرأ إن الحالة دائماً "نشط"
    Class dataManager = objc_getClass("WizardDataManager");
    if (dataManager) {
        class_replaceMethod(dataManager, @selector(isLocalKeyValid), (IMP)returnTrue, "B@:");
    }

    // 4. إظهار رسالة DooN UP ✅ بعد استقرار اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"تم دمج الملفات وتخطي الحماية بنجاح\nكل شيء جاهز للعمل" 
                                          preferredStyle:UIAlertControllerStyleAlert];
                                          
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}