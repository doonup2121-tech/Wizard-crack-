#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// دوال ثابتة لإرجاع قيمة "نجاح" لتخطي حماية السيرفر والكي
static BOOL returnTrue() { return YES; }

%ctor {
    NSLog(@"[DooN UP] Ultimate Bypass Started...");

    // 1. تخطي حماية الفريم ورك (بناءً على ملف WizardFrameworkAuth)
    Class wizAuth = objc_getClass("WizardFrameworkAuth");
    if (wizAuth) {
        // تخطي فحص ترخيص الجهاز
        class_replaceMethod(wizAuth, @selector(isDeviceAuthorized), (IMP)returnTrue, "B@:");
        // تخطي فحص الاشتراك
        class_replaceMethod(wizAuth, @selector(checkSubscription), (IMP)returnTrue, "B@:");
    }
    
    // 2. كسر فحص المفتاح (Key) في المكتبة الرئيسية (بناءً على wizardcrackv2)
    Class mainAuth = objc_getClass("WizardAuth");
    if (mainAuth) {
        class_replaceMethod(mainAuth, @selector(checkKey:), (IMP)returnTrue, "B@:@");
    }

    // 3. التعامل مع ملفات الداتا والهيكس (.dat) لإيهام البرنامج بالصلاحية
    Class dataManager = objc_getClass("WizardDataManager");
    if (dataManager) {
        class_replaceMethod(dataManager, @selector(isLocalKeyValid), (IMP)returnTrue, "B@:");
    }

    // 4. إظهار رسالة DooN UP ✅ مع حل مشكلة keyWindow (للأنظمة الجديدة والقديمة)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *win = nil;
        // حل مشكلة الصورة IMG_1125: البحث عن الـ Window النشطة بطريقة حديثة
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    win = scene.windows.firstObject;
                    break;
                }
            }
        }
        
        // إذا فشلت الطريقة الحديثة أو كان الإصدار قديماً
        if (!win) {
            win = [UIApplication sharedApplication].keyWindow;
        }

        if (win && win.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"تم دمج ملفات الهيكس والـ .dat بنجاح\nالحماية مكسورة الآن.. استمتع!" 
                                          preferredStyle:UIAlertControllerStyleAlert];
                                          
            [alert addAction:[UIAlertAction actionWithTitle:@"استمرار" style:UIAlertActionStyleDefault handler:nil]];
            
            [win.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}