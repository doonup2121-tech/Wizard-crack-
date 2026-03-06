#import <UIKit/UIKit.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netdb.h>

@interface StealthProvider : NSObject
+ (void)initializeService;
@end

@implementation StealthProvider

static UIView *mainOverlay;

+ (void)initializeService {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;

        mainOverlay = [[UIView alloc] initWithFrame:win.bounds];
        mainOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        [win addSubview:mainOverlay];

        UIButton *verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        verifyBtn.frame = CGRectMake(0, 0, 220, 55);
        verifyBtn.center = win.center;
        verifyBtn.backgroundColor = [UIColor systemBlueColor];
        verifyBtn.layer.cornerRadius = 12;
        [verifyBtn setTitle:@"ACTIVATE" forState:UIControlStateNormal];
        [mainOverlay addSubview:verifyBtn];

        [verifyBtn addTarget:self action:@selector(lowLevelCheck) forControlEvents:UIControlEventTouchUpInside];
    });
}

// استخدام Socket C-Function بدلاً من NSURLSession (لتخطي الرقابة)
+ (void)lowLevelCheck {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        const char *host = "HostDooN.xo.je";
        const char *path = "/check.php?key=TEST&udid=8282";
        
        struct hostent *server = gethostbyname(host);
        if (server == NULL) { exit(0); }

        int sockfd = socket(AF_INET, SOCK_STREAM, 0);
        if (sockfd < 0) { exit(0); }

        struct sockaddr_in serv_addr;
        memset(&serv_addr, 0, sizeof(serv_addr));
        serv_addr.sin_family = AF_INET;
        memcpy(&serv_addr.sin_addr.s_addr, server->h_addr, server->h_length);
        serv_addr.sin_port = htons(80);

        // محاولة الاتصال (هذه الخطوة عادة لا تراقبها الحماية لأنها Low-Level)
        if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
            close(sockfd);
            return;
        }

        // بناء طلب HTTP يدوي (Raw HTTP Request)
        NSString *rawRequest = [NSString stringWithFormat:
                                @"GET %s HTTP/1.1\r\n"
                                "Host: %s\r\n"
                                "User-Agent: Mozilla/5.0\r\n"
                                "Connection: close\r\n\r\n", path, host];
        
        const char *msg = [rawRequest UTF8String];
        send(sockfd, msg, strlen(msg), 0);

        char buffer[1024];
        memset(buffer, 0, 1024);
        recv(sockfd, buffer, 1023, 0);
        close(sockfd);

        NSString *response = [NSString stringWithUTF8String:buffer];
        
        if ([response containsString:@"YES"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [mainOverlay removeFromSuperview];
                mainOverlay = nil;
            });
        } else {
            exit(0);
        }
    });
}
@end

%ctor {
    [StealthProvider initializeService];
}
