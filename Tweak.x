#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// دوال النجاح والتاريخ الأبدي
static BOOL returnTrue() { return YES; }
static id returnNil() { return nil; }
static NSString* returnInfiniteDate() { return @"Key expire: 01.01.2099 13:37"; }

%ctor {
    // كسر كلاسات PIXEL RAID وفريمورك الويزارد
    NSArray *classes = @[@"PixelRaidAuth", @"PixelRaidMenu", @"AuthManager", @"WizardAuth"];
    for (NSString *className in classes) {
        Class cls = objc_getClass([className UTF8String]);
        if (cls) {
            class_replaceMethod(cls, @selector(checkKey:), (IMP)returnTrue, "B@:@");
            class_replaceMethod(cls, @selector(isDeviceAuthorized), (IMP)returnTrue, "B@:");
            class_replaceMethod(cls, @selector(getExpiryDateString), (IMP)returnInfiniteDate, "@@:");
        }
    }

    // منع رسالة الخطأ "Key is invalid"
    Class alertCls = objc_getClass("SCLAlertView");
    if (alertCls) {
        class_replaceMethod(alertCls, @selector(showError:subTitle:closeButtonTitle:duration:), (IMP)returnNil, "v@:@@@d");
    }

    // إظهار الرسالة الترحيبية بطريقة حديثة (تجنب خطأ IMG_1134)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        }
        
        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"تم التفعيل للأبد بنجاح" 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"استمتع" style:0 handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}