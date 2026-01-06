#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static BOOL returnTrue() { return YES; }

%ctor {
    // 1. تفعيل الخصائص وكسر الحماية بناءً على ملفات Wizard
    Class wizardCls = objc_getClass("Wizard");
    if (wizardCls) {
        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)returnTrue, "B@:");
        class_replaceMethod(wizardCls, @selector(checkKey:), (IMP)returnTrue, "B@:@");
    }

    // 2. كسر حماية Pixel Raid ومنع رسائل الخطأ
    NSArray *authClasses = @[@"PixelRaidAuth", @"AuthManager", @"SCLAlertView"];
    for (NSString *className in authClasses) {
        Class cls = objc_getClass([className UTF8String]);
        if (cls) {
            class_replaceMethod(cls, @selector(isAuthorized), (IMP)returnTrue, "B@:");
            class_replaceMethod(cls, @selector(showError:subTitle:closeButtonTitle:duration:), (IMP)nil, "v@:@@@d");
        }
    }

    // 3. إظهار رسالة DooN UP عند تشغيل اللعبة (متوافق مع iOS 18)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        // التأكد من الوصول للنافذة الصحيحة لتجنب أخطاء keyWindow القديمة
        UIWindow *window = nil;
        for (UIWindow *w in scene.windows) {
            if (w.isKeyWindow) {
                window = w;
                break;
            }
        }
        if (!window) window = scene.windows.firstObject;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                      message:@"Welcome Back" 
                                      preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}