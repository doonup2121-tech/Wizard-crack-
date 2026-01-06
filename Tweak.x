#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static BOOL returnTrue() { return YES; }
// دالة فاضية عشان المصنع ميعترضش على الـ nil
static void emptyFunction() { } 

%ctor {
    // 1. تفعيل الخصائص
    Class wizardCls = objc_getClass("Wizard");
    if (wizardCls) {
        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)returnTrue, "B@:");
    }

    // 2. كسر الحماية ومنع رسائل الخطأ بطريقة صحيحة
    NSArray *authClasses = @[@"PixelRaidAuth", @"AuthManager", @"SCLAlertView"];
    for (NSString *className in authClasses) {
        Class cls = objc_getClass([className UTF8String]);
        if (cls) {
            class_replaceMethod(cls, @selector(isAuthorized), (IMP)returnTrue, "B@:");
            // هنا التعديل: استبدال nil بـ emptyFunction لحل خطأ الصورة
            class_replaceMethod(cls, @selector(showError:subTitle:closeButtonTitle:duration:), (IMP)emptyFunction, "v@:@@@d");
        }
    }

    // 3. رسالة DooN UP ✅
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" message:@"Ready to Go" preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
        [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}