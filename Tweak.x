#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h> 

#define SERVER_URL @"http://HostDooN.xo.je/check.php"

@interface IOSInternalProvider : NSObject <UITextFieldDelegate>
+ (void)setupInternalService;
@end

@implementation IOSInternalProvider

static NSTimer *internalTimer;
static UIView *globalViewContainer; 

+ (void)verifyIntegrity {
    BOOL isFound = NO;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count ; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name != NULL && (strstr(name, "DoonN_Wizard") || strstr(name, "DoonN_Wizard.dylib"))) {
            isFound = YES;
            break;
        }
    }
    if (!isFound) { exit(0); }
}

+ (void)setupInternalService {
    [self verifyIntegrity];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;

        if (!window || !window.rootViewController) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setupInternalService];
            });
            return;
        }

        if ([window viewWithTag:8822]) return;

        globalViewContainer = [[UIView alloc] initWithFrame:window.bounds];
        globalViewContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
        globalViewContainer.tag = 8822;
        [window addSubview:globalViewContainer];

        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 330)];
        box.center = CGPointMake(window.center.x, window.center.y - 80);
        box.backgroundColor = [UIColor whiteColor];
        box.layer.cornerRadius = 18;
        [globalViewContainer addSubview:box];

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

        [exitBtn addTarget:self action:@selector(handleClose) forControlEvents:UIControlEventTouchUpInside];
        [okBtn addTarget:self action:@selector(processRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        objc_setAssociatedObject(okBtn, "fRef", keyField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        internalTimer = [NSTimer scheduledTimerWithTimeInterval:120.0 repeats:NO block:^(NSTimer *timer) {
            exit(0); 
        }];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [IOSInternalProvider runTaskWithData:textField.text];
    return YES;
}

+ (void)handleClose { exit(0); }

+ (void)processRequest:(UIButton *)sender {
    UITextField *field = objc_getAssociatedObject(sender, "fRef");
    if (field && field.text.length > 0) {
        [self runTaskWithData:[NSString stringWithString:field.text]];
    }
}

+ (void)runTaskWithData:(NSString *)input {
    // جلب الـ UDID الحقيقي في الخيط الرئيسي قبل الدخول في الطلب الخلفي لتجنب تضارب الذاكرة
    __block NSString *realUDID = @"UNKNOWN";
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        realUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));

        NSString *clean = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // بناء الرابط بالـ UDID الحقيقي الذي جلبناه
        NSString *target = [NSString stringWithFormat:@"%@?key=%@&udid=%@", SERVER_URL, clean, realUDID];
        
        NSURL *url = [NSURL URLWithString:[target stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        cfg.HTTPAdditionalHeaders = @{@"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)"};
        
        [[[NSURLSession sessionWithConfiguration:cfg] dataTaskWithURL:url completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
            if (e || !d) exit(0);

            NSString *sResp = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
            NSString *finalResp = [sResp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if ([finalResp containsString:@"YES"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [internalTimer invalidate];
                    if (globalViewContainer) {
                        [globalViewContainer removeFromSuperview];
                        globalViewContainer = nil;
                    }
                });
            } else {
                exit(0);
            }
        }] resume];
    });
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [IOSInternalProvider setupInternalService];
    });
}
