#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// إعداداتك الخاصة
static NSString *mySecretKey = @"123456";

// دالة حساب شهر (30 يوم) من الآن
static long long getExpiryDateForTest() {
    return (long long)[[NSDate date] timeIntervalSince1970] + (30 * 24 * 60 * 60);
}

%ctor {
    // استهداف الكلاس المسؤول داخل wizardcrackv2
    Class wizardCls = objc_getClass("Wizard");
    
    if (wizardCls) {
        // 1. تخصيص الكود ليكون 123456 فقط
        MSHookMessageEx(wizardCls, @selector(checkKey:), (IMP)^BOOL(id self, SEL _cmd, NSString *input) {
            if ([input isEqualToString:mySecretKey]) {
                return YES;
            }
            return NO;
        }, NULL);

        // 2. إجبار النظام على رؤية المفتاح كأنه صالح دائمًا بعد إدخاله
        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)^BOOL(id self){ return YES; }, "B@:");

        // 3. تحديد مدة الصلاحية بشهر واحد (اختبار)
        class_replaceMethod(wizardCls, @selector(getExpiryDate), (IMP)getOneMonthExpiry, "q@:");
        
        // 4. تفعيل مميزات الـ VIP تلقائيًا
        class_replaceMethod(wizardCls, @selector(isVip), (IMP)^BOOL(id self){ return YES; }, "B@:");
    }

    // رسالة البداية (بصمتك الخاصة)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                      message:@"Wizard Crack Controlled\nKey: 123456\nStatus: 30 Days Active" 
                                      preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"Start Playing" style:0 handler:nil]];
        [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}