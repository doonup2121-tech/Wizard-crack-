#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// --- [ قسم الإضافات والدوال الثابتة ] ---

// دالة لفرض حالة "النجاح" دائماً
static BOOL returnTrue() { return YES; }

// دالة لإخفاء أي نص خطأ (nil)
static id returnNil() { return nil; }

// دالة التاريخ الأبدي للمنيو
static NSString* returnInfiniteDate() { return @"Key expire: 01.01.2099 13:37"; }

// --- [ بداية عملية الاختراق والدمج ] ---

%ctor {
    // 1. استهداف كلاسات PIXEL RAID وفريمورك Wizard بناءً على فحصنا
    NSArray *classes = @[@"PixelRaidAuth", @"PixelRaidMenu", @"AuthManager", @"WizardAuth", @"WizardFrameworkAuth"];
    
    for (NSString *className in classes) {
        Class cls = objc_getClass([className UTF8String]);
        if (cls) {
            // كسر فحص المفتاح وتخطي واجهة Welcome
            class_replaceMethod(cls, @selector(checkKey:), (IMP)returnTrue, "B@:@");
            class_replaceMethod(cls, @selector(isDeviceAuthorized), (IMP)returnTrue, "B@:");
            class_replaceMethod(cls, @selector(validateKey:), (IMP)returnTrue, "B@:@");
            class_replaceMethod(cls, @selector(isKeyValid), (IMP)returnTrue, "B@:");
            
            // إضافة: تخطي السيرفر ومنع تأخير الثانيتين
            class_replaceMethod(cls, @selector(validateRemoteKey:), (IMP)returnTrue, "B@:@");
            
            // إضافة: تثبيت التاريخ الأبدي في واجهة المنيو
            class_replaceMethod(cls, @selector(getExpiryDateString), (IMP)returnInfiniteDate, "@@:");
            class_replaceMethod(cls, @selector(getExpirationDate), (IMP)returnInfiniteDate, "@@:");
        }
    }

    // 2. إضافة منع رسالة الخطأ "Key is invalid"
    // بنستهدف كلاس التنبيهات SCLAlertView اللي بيظهر في الصورة
    Class alertCls = objc_getClass("SCLAlertView");
    if (alertCls) {
        // لو اللعبة حاولت تنادي دالة showError، الكود هيخليها متعملش حاجة
        class_replaceMethod(alertCls, @selector(showError:subTitle:closeButtonTitle:duration:), (IMP)returnNil, "v@:@@@d");
        // وأيضاً منع رسائل الـ Notice والـ Warning عشان نضمن سلاسة الدخول
        class_replaceMethod(alertCls, @selector(showNotice:subTitle:closeButtonTitle:duration:), (IMP)returnNil, "v@:@@@d");
    }

    // 3. رسالة DooN UP ✅ النهائية للتأكيد
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win && win.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"تم دمج كل الإضافات:\n- تخطي الحماية\n- منع رسائل الخطأ\n- اشتراك أبدي (2099)" 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"دخول مباشر" style:0 handler:nil]];
            [win.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}