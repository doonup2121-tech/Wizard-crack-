#import <UIKit/UIKit.h>

// إعدادات السيرفر
#define SERVER_URL @"http://HostDooN.xo.je/check.php"

@interface DoonSecurity : NSObject
+ (void)showLogin;
@end

@implementation DoonSecurity

static NSTimer *lockTimer;

+ (void)showLogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Welcome" 
                                    message:@"Please enter your key\n(Closing in 10s)" 
                                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
            textField.secureTextEntry = YES;
            textField.backgroundColor = [UIColor blackColor];
            textField.textColor = [UIColor whiteColor];
        }];

        // زر التأكيد
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [lockTimer invalidate]; // إيقاف مؤقت الطوارئ
            [self verifyKey:alert.textFields.firstObject.text];
        }];

        // زر الخروج
        UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            exit(0);
        }];

        [alert addAction:okAction];
        [alert addAction:exitAction];

        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];

        // مؤقت الـ 10 ثواني للإغلاق التلقائي
        lockTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            exit(0);
        }];
    });
}

+ (void)verifyKey:(NSString *)key {
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *fullUrl = [NSString stringWithFormat:@"%@?key=%@&udid=%@", SERVER_URL, key, udid];
    
    // طلب التحقق من السيرفر
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:fullUrl] encoding:NSUTF8StringEncoding error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response && [response containsString:@"YES"]) {
                // استخراج تاريخ الانتهاء من رد السيرفر (نفترض أن السيرفر يرد بـ YES|2024-12-31 23:59)
                NSArray *parts = [response componentsSeparatedByString:@"|"];
                NSString *expiryDate = (parts.count > 1) ? parts[1] : @"Unknown";

                UIAlertController *success = [UIAlertController alertControllerWithTitle:@"Access Granted" 
                                             message:[NSString stringWithFormat:@"License expires on:\n%@", expiryDate] 
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                [success addAction:[UIAlertAction actionWithTitle:@"Start Game" style:UIAlertActionStyleDefault handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:success animated:YES completion:nil];
            } else {
                exit(0); // حماية: إغلاق اللعبة فوراً إذا فشل التحقق
            }
        });
    });
}

@end

%ctor {
    // الانتظار حتى استقرار واجهة اللعبة ثم إظهار القفل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DoonSecurity showLogin];
    });
}
