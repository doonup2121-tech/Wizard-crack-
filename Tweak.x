#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h> 

#define SERVER_URL @"http://HostDooN.xo.je/check.php"

@interface DoonSecurity : NSObject <UITextFieldDelegate>
+ (void)launchSecurity;
@end

@implementation DoonSecurity

static NSTimer *timeoutTimer;
static UIView *mainOverlay; 

+ (void)checkLibraryIntegrity {
    BOOL isLoaded = NO;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count ; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name != NULL && (strstr(name, "DoonN_Wizard") || strstr(name, "DoonN_Wizard.dylib"))) {
            isLoaded = YES;
            break;
        }
    }
    if (!isLoaded) { exit(0); }
}

+ (void)launchSecurity {
    // استدعاء فحص السلامة
    [self checkLibraryIntegrity];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    keyWindow = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!keyWindow) keyWindow = [UIApplication sharedApplication].keyWindow;

        if (!keyWindow || !keyWindow.rootViewController) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self launchSecurity];
            });
            return;
        }

        if ([keyWindow viewWithTag:9999]) return;

        mainOverlay = [[UIView alloc] initWithFrame:keyWindow.bounds];
        mainOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
        mainOverlay.tag = 9999;
        [keyWindow addSubview:mainOverlay];

        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 330)];
        box.center = CGPointMake(keyWindow.center.x, keyWindow.center.y - 80);
        box.backgroundColor = [UIColor whiteColor];
        box.layer.cornerRadius = 18;
        [mainOverlay addSubview:box];

        UIView *iconCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        iconCircle.backgroundColor = [UIColor colorWithRed:0.23 green:0.48 blue:0.85 alpha:1.0];
        iconCircle.layer.cornerRadius = 30;
        iconCircle.center = CGPointMake(155, 0); 
        iconCircle.layer.borderWidth = 3;
        iconCircle.layer.borderColor = [UIColor whiteColor].CGColor;
        [box addSubview:iconCircle];

        UILabel *iconLabel = [[UILabel alloc] initWithFrame:iconCircle.bounds];
        iconLabel.text = @"i";
        iconLabel.textColor = [UIColor whiteColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.font = [UIFont boldSystemFontOfSize:35];
        [iconCircle addSubview:iconLabel];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 310, 35)];
        titleLabel.text = @"Welcome";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:24];
        titleLabel.textColor = [UIColor blackColor];
        [box addSubview:titleLabel];

        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 270, 40)];
        msgLabel.text = @"Please enter your key";
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.font = [UIFont systemFontOfSize:15];
        msgLabel.textColor = [UIColor darkGrayColor];
        msgLabel.numberOfLines = 0;
        [box addSubview:msgLabel];

        UITextField *keyField = [[UITextField alloc] initWithFrame:CGRectMake(25, 145, 260, 45)];
        keyField.backgroundColor = [UIColor blackColor];
        keyField.textColor = [UIColor whiteColor];
        keyField.placeholder = @"Key";
        keyField.layer.cornerRadius = 8;
        keyField.textAlignment = NSTextAlignmentCenter;
        keyField.font = [UIFont boldSystemFontOfSize:17];
        keyField.keyboardAppearance = UIKeyboardAppearanceDark;
        keyField.returnKeyType = UIReturnKeyDone; 
        keyField.delegate = (id<UITextFieldDelegate>)self; 
        
        NSDictionary *attr = @{NSForegroundColorAttributeName: [UIColor grayColor]};
        keyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Key" attributes:attr];
        [box addSubview:keyField];

        UIColor *doonBlue = [UIColor colorWithRed:0.23 green:0.48 blue:0.85 alpha:1.0];

        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        okBtn.frame = CGRectMake(25, 205, 260, 48);
        okBtn.backgroundColor = doonBlue;
        [okBtn setTitle:@"OK" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        okBtn.layer.cornerRadius = 8;
        okBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [box addSubview:okBtn];

        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        exitBtn.frame = CGRectMake(25, 265, 260, 48);
        exitBtn.backgroundColor = doonBlue;
        [exitBtn setTitle:@"Exit" forState:UIControlStateNormal];
        [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        exitBtn.layer.cornerRadius = 8;
        exitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [box addSubview:exitBtn];

        [exitBtn addTarget:self action:@selector(handleExit) forControlEvents:UIControlEventTouchUpInside];
        [okBtn addTarget:self action:@selector(onOkPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        objc_setAssociatedObject(okBtn, "fieldRef", keyField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:120.0 repeats:NO block:^(NSTimer *timer) {
            exit(0); 
        }];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [DoonSecurity verifyWithServer:textField.text];
    return YES;
}

+ (void)handleExit { exit(0); }

+ (void)onOkPressed:(UIButton *)sender {
    UITextField *field = objc_getAssociatedObject(sender, "fieldRef");
    if (field && field.text) {
        NSString *txt = [NSString stringWithString:field.text];
        [self verifyWithServer:txt];
    }
}

+ (void)verifyWithServer:(NSString *)userKey {
    if (!userKey || userKey.length < 1) return;

    // فصل الطلب تماماً عن أي كائن UI لمنع الكراش
    NSString *cleanKey = [userKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // استخدام "ID" عشوائي ثابت كبداية لتجاوز حماية الجهاز
    NSString *urlStr = [NSString stringWithFormat:@"%@?key=%@&udid=DE_BOX_ID", SERVER_URL, cleanKey];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    // استخدام Session مستقل تماماً
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) { exit(0); }

        NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([res containsString:@"YES"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [timeoutTimer invalidate];
                [mainOverlay removeFromSuperview];
                mainOverlay = nil;
            });
        } else {
            exit(0);
        }
    }] resume];
}
@end

%ctor {
    // زيادة وقت الظهور لـ 5 ثواني لضمان استقرار محرك اللعبة تماماً
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DoonSecurity launchSecurity];
    });
}
