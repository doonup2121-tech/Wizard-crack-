#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static BOOL returnTrue() { return YES; }
// دالة فارغة لتجنب خطأ null في الإصدارات الجديدة
static void emptyFunc(id self, SEL _cmd, id arg1, id arg2, id arg3, double arg4) { }

%ctor {
    // 1. تفعيل المنيو (Wizard)
    Class wizardCls = objc_getClass("Wizard");
    if (wizardCls) {
        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)returnTrue, "B@:");
        class_replaceMethod(wizardCls, @selector(checkKey:), (IMP)returnTrue, "B@:@");
    }

    // 2. تفعيل الخطوط الطويلة لنسخة 56.13.0
    // استهداف كلاسات الـ Rendering مباشرة
    NSArray *poolClasses = @[@"GameSettings", @"PoolPhysics", @"TrajectoryManager"];
    for (NSString *name in poolClasses) {
        Class cls = objc_getClass([name UTF8String]);
        if (cls) {
            class_replaceMethod(cls, @selector(isGuidelineEnabled), (IMP)returnTrue, "B@:");
            class_replaceMethod(cls, @selector(isLongLine), (IMP)returnTrue, "B@:");
        }
    }

    // 3. حل مشكلة الخطأ Error 10 (IMG_1136)
    Class alertCls = objc_getClass("SCLAlertView");
    if (alertCls) {
        class_replaceMethod(alertCls, @selector(showError:subTitle:closeButtonTitle:duration:), (IMP)emptyFunc, "v@:@@@d");
    }

    // 4. رسالة DooN UP ✅
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                      message:@"8 Ball Pool 56.13.0 Fixed" 
                                      preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"GO" style:0 handler:nil]];
        [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}