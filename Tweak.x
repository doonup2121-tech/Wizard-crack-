#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// دالة ثابتة لإرجاع قيمة "نجاح" (YES) لتخطي الفحوصات
static BOOL returnTrue() { return YES; }

%ctor {
    NSLog(@"[DooN UP] Ultimate Bypass Started...");

    // 1. كسر حماية الفريم ورك (WizardFrameworkAuth)
    Class wizAuth = objc_getClass("WizardFrameworkAuth");
    if (wizAuth) {
        class_replaceMethod(wizAuth, @selector(isDeviceAuthorized), (IMP)returnTrue, "B@:");
        class_replaceMethod(wizAuth, @selector(checkSubscription), (IMP)returnTrue, "B@:");
    }
    
    // 2. كسر فحص المفتاح (WizardAuth) المستنتج من الديلب القديم
    Class mainAuth = objc_getClass("WizardAuth");
    if (mainAuth) {
        class_replaceMethod(mainAuth, @selector(checkKey:), (IMP)returnTrue, "B@:@");
    }

    // 3. تخطي فحص البيانات المحلية (.dat)
    Class dataManager = objc_getClass("WizardDataManager");
    if (dataManager) {
        class_replaceMethod(dataManager, @selector(isLocalKeyValid), (IMP)returnTrue, "B@:");
    }

    // 4. إظهار رسالة الترحيب DooN UP ✅ مع معالجة خطأ keyWindow
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = nil;
        // محاولة الحصول على النافذة بطريقة متوافقة مع iOS 13+ لتجنب أخطاء البناء
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        }
        
        if (!window) {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"تم دمج الملفات وتخطي الحماية بنجاح\nاستمتع يا وحش" 
                                          preferredStyle:UIAlertControllerStyleAlert];
                                          
            [alert addAction:[UIAlertAction actionWithTitle:@"دخول" style:UIAlertActionStyleDefault handler:nil]];
            
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}